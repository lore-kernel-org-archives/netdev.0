From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.12-rc5 8/9] tg3: Add interrupt test
Date: Thu, 26 May 2005 10:59:29 -0700
Message-ID: <1117130369.3744.60.camel@rh4>
References: <1117128795.3744.22.camel@rh4>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=-xExx4ZEVLFBGOZNm0WqK"
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <1117128795.3744.22.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-xExx4ZEVLFBGOZNm0WqK
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This test uses the previously added tg3_test_interrupt() to perform the
test.

Signed-off-by: Michael Chan <mchan@broadcom.com>

--=-xExx4ZEVLFBGOZNm0WqK
Content-Disposition: attachment;
 filename=tg3-d8.patch
Content-Type: text/x-patch;
 charset=utf-8;
 name=tg3-d8.patch
Content-Transfer-Encoding: base64

ZGlmZiAtTnJ1IGQ3L2RyaXZlcnMvbmV0L3RnMy5jIGQ4L2RyaXZlcnMvbmV0L3RnMy5jDQotLS0g
ZDcvZHJpdmVycy9uZXQvdGczLmMJMjAwNS0wNS0yNSAxMjo1OTozOC4wMDAwMDAwMDAgLTA3MDAN
CisrKyBkOC9kcml2ZXJzL25ldC90ZzMuYwkyMDA1LTA1LTI1IDEyOjU5OjQ2LjAwMDAwMDAwMCAt
MDcwMA0KQEAgLTU4OTQsNiArNTg5NCw5IEBADQogCWludCBlcnIsIGk7DQogCXUzMiBpbnRfbWJv
eCA9IDA7DQogDQorCWlmICghbmV0aWZfcnVubmluZyhkZXYpKQ0KKwkJcmV0dXJuIC1FTk9ERVY7
DQorDQogCXRnM19kaXNhYmxlX2ludHModHApOw0KIA0KIAlmcmVlX2lycSh0cC0+cGRldi0+aXJx
LCBkZXYpOw0KQEAgLTc3MjksNiArNzczMiwxNSBAQA0KIAkJCWRhdGFbNF0gPSAxOw0KIAkJfQ0K
IA0KKwkJc3Bpbl91bmxvY2soJnRwLT50eF9sb2NrKTsNCisJCXNwaW5fdW5sb2NrX2lycSgmdHAt
PmxvY2spOw0KKwkJaWYgKHRnM190ZXN0X2ludGVycnVwdCh0cCkgIT0gMCkgew0KKwkJCWV0ZXN0
LT5mbGFncyB8PSBFVEhfVEVTVF9GTF9GQUlMRUQ7DQorCQkJZGF0YVs1XSA9IDE7DQorCQl9DQor
CQlzcGluX2xvY2tfaXJxKCZ0cC0+bG9jayk7DQorCQlzcGluX2xvY2soJnRwLT50eF9sb2NrKTsN
CisNCiAJCXRnM19oYWx0KHRwLCBSRVNFVF9LSU5EX1NIVVRET1dOLCAxKTsNCiAJCWlmIChuZXRp
Zl9ydW5uaW5nKGRldikpIHsNCiAJCQl0cC0+dGczX2ZsYWdzIHw9IFRHM19GTEFHX0lOSVRfQ09N
UExFVEU7DQo=


--=-xExx4ZEVLFBGOZNm0WqK--
