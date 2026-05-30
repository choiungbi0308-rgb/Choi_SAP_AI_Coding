import requests
import base64
import xml.etree.ElementTree as ET
import sys

# SAP Connection — set via environment variables or .env file
SAP_URL  = "http://<SAP_HOST>:<SAP_PORT>"
CLIENT   = "100"
USER     = "<SAP_USER>"
PASSWORD = "<SAP_PASSWORD>"
SOAP_URL = f"{SAP_URL}/sap/bc/soap/rfc"

PO_NUMBER = "3901535866"
SO_NUMBER = "5700416643"
REJ_CODE  = "06"

HEADERS = {
    "Content-Type": "text/xml; charset=utf-8",
    "SOAPAction": "urn:sap-com:document:sap:rfc:functions",
    "sap-client": CLIENT,
}
AUTH = (USER, PASSWORD)

NS = "urn:sap-com:document:sap:rfc:functions"
NS_ENV = "http://schemas.xmlsoap.org/soap/envelope/"


def soap_call(func_name, body_xml):
    envelope = f"""<?xml version="1.0" encoding="utf-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="{NS_ENV}">
  <SOAP-ENV:Body>
    <{func_name} xmlns="{NS}">
      {body_xml}
    </{func_name}>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>"""
    resp = requests.post(SOAP_URL, data=envelope.encode("utf-8"),
                         headers=HEADERS, auth=AUTH, timeout=30)
    print(f"  [{func_name}] HTTP {resp.status_code}")
    return resp.status_code, resp.text


def parse_return(xml_text, return_tag="RETURN"):
    """Extract RETURN messages from BAPI response."""
    try:
        root = ET.fromstring(xml_text)
        msgs = []
        for item in root.iter("item"):
            type_el = item.find("TYPE")
            msg_el  = item.find("MESSAGE")
            if type_el is not None and msg_el is not None:
                msgs.append(f"[{type_el.text}] {msg_el.text}")
        return msgs
    except Exception as e:
        return [f"parse error: {e}"]


def get_table_rows(table_name, fields, where_clause, max_rows=50):
    """RFC_READ_TABLE로 테이블 조회"""
    fields_xml = "".join(f"<item><FIELDNAME>{f}</FIELDNAME></item>" for f in fields)
    where_xml  = f"<item><TEXT>{where_clause}</TEXT></item>"
    body = f"""
<QUERY_TABLE>{table_name}</QUERY_TABLE>
<DELIMITER>|</DELIMITER>
<ROWCOUNT>{max_rows}</ROWCOUNT>
<FIELDS>{fields_xml}</FIELDS>
<OPTIONS>{where_xml}</OPTIONS>"""
    status, xml_text = soap_call("RFC_READ_TABLE", body)
    if status != 200:
        return []
    try:
        root = ET.fromstring(xml_text)
        rows = []
        for item in root.iter("{urn:sap-com:document:sap:rfc:functions}item"):
            wa = item.find("{urn:sap-com:document:sap:rfc:functions}WA")
            if wa is not None and wa.text:
                rows.append(wa.text.strip())
        if not rows:
            for item in root.iter("item"):
                wa = item.find("WA")
                if wa is not None and wa.text:
                    rows.append(wa.text.strip())
        return rows
    except Exception as e:
        print(f"  parse error: {e}")
        return []


# STEP 1: PO 아이템 조회
print(f"\n{'='*50}")
print(f"STEP 1: PO {PO_NUMBER} 아이템 조회 (EKPO)")
print('='*50)
rows = get_table_rows("EKPO", ["EBELN","EBELP","LOEKZ","MENGE"],
                      f"EBELN EQ '{PO_NUMBER}'")
po_items = []
if rows:
    for r in rows:
        parts = [p.strip() for p in r.split("|")]
        print(f"  PO={parts[0] if len(parts)>0 else ''} Item={parts[1] if len(parts)>1 else ''} LOEKZ={parts[2] if len(parts)>2 else ''}")
        if len(parts) >= 2:
            po_items.append(parts[1].zfill(5))
else:
    print("  EKPO 조회 실패 - item 00010 기본값 사용")
    po_items = ["00010"]

print(f"  처리할 PO 아이템: {po_items}")
