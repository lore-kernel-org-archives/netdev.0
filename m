From: Wensong Zhang <wensong@linux-vs.org>
Subject: [PATCH] Update IPVS version number
Date: Fri, 29 Oct 2004 00:21:27 +0800 (CST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410290017450.5836-300000@penguin.linux-vs.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811584-128716279-1098980487=:5836"
Cc: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---1463811584-128716279-1098980487=:5836
Content-Type: TEXT/PLAIN; charset=US-ASCII



Hi Dave,

Since there are some fixes in the IPVS code, it's good to update its 
version number. Please help apply the version number patch to kernel 2.6 
and 2.4 respectively.

Thanks,

Wensong

---1463811584-128716279-1098980487=:5836
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="linux-2.4-ipvs-version.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0410290021270.5836@penguin.linux-vs.org>
Content-Description: 
Content-Disposition: attachment; filename="linux-2.4-ipvs-version.patch"

IyBUaGlzIGlzIGEgQml0S2VlcGVyIGdlbmVyYXRlZCBkaWZmIC1OcnUgc3R5
bGUgcGF0Y2guDQojDQojIENoYW5nZVNldA0KIyAgIDIwMDQvMTAvMjkgMDA6
MDc6MzIrMDg6MDAgd2Vuc29uZ0BsaW51eC12cy5vcmcgDQojICAgW0lQVlNd
IHVwZGF0ZSB2ZXJzaW9uIHRvIDEuMC4xMg0KIyANCiMgaW5jbHVkZS9uZXQv
aXBfdnMuaA0KIyAgIDIwMDQvMTAvMjkgMDA6MDc6MjYrMDg6MDAgd2Vuc29u
Z0BsaW51eC12cy5vcmcgKzEgLTENCiMgICBbSVBWU10gdXBkYXRlIHZlcnNp
b24gdG8gMS4wLjEyDQojIA0KZGlmZiAtTnJ1IGEvaW5jbHVkZS9uZXQvaXBf
dnMuaCBiL2luY2x1ZGUvbmV0L2lwX3ZzLmgNCi0tLSBhL2luY2x1ZGUvbmV0
L2lwX3ZzLmgJMjAwNC0xMC0yOSAwMDoxNTo1MCArMDg6MDANCisrKyBiL2lu
Y2x1ZGUvbmV0L2lwX3ZzLmgJMjAwNC0xMC0yOSAwMDoxNTo1MCArMDg6MDAN
CkBAIC04LDcgKzgsNyBAQA0KIA0KICNpbmNsdWRlIDxhc20vdHlwZXMuaD4g
ICAgICAgICAgLyogRm9yIF9fdVhYIHR5cGVzICovDQogDQotI2RlZmluZSBJ
UF9WU19WRVJTSU9OX0NPREUgICAgICAgICAgICAweDAxMDAwQg0KKyNkZWZp
bmUgSVBfVlNfVkVSU0lPTl9DT0RFICAgICAgICAgICAgMHgwMTAwMEMNCiAj
ZGVmaW5lIE5WRVJTSU9OKHZlcnNpb24pICAgICAgICAgICAgICAgICAgICAg
ICBcDQogCSh2ZXJzaW9uID4+IDE2KSAmIDB4RkYsICAgICAgICAgICAgICAg
ICBcDQogCSh2ZXJzaW9uID4+IDgpICYgMHhGRiwgICAgICAgICAgICAgICAg
ICBcDQo=
---1463811584-128716279-1098980487=:5836
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="linux-2.6-ipvs-version.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0410290021271.5836@penguin.linux-vs.org>
Content-Description: 
Content-Disposition: attachment; filename="linux-2.6-ipvs-version.patch"

IyBUaGlzIGlzIGEgQml0S2VlcGVyIGdlbmVyYXRlZCBkaWZmIC1OcnUgc3R5
bGUgcGF0Y2guDQojDQojIENoYW5nZVNldA0KIyAgIDIwMDQvMTAvMjkgMDA6
MTQ6MTMrMDg6MDAgd2Vuc29uZ0BsaW51eC12cy5vcmcgDQojICAgW0lQVlNd
IFVwZGF0ZSB2ZXJzaW9uIHRvIDEuMi4xDQojIA0KIyBpbmNsdWRlL25ldC9p
cF92cy5oDQojICAgMjAwNC8xMC8yOSAwMDoxMzo1NSswODowMCB3ZW5zb25n
QGxpbnV4LXZzLm9yZyArMSAtMQ0KIyAgIFtJUFZTXSBVcGRhdGUgdmVyc2lv
biB0byAxLjIuMQ0KIyANCmRpZmYgLU5ydSBhL2luY2x1ZGUvbmV0L2lwX3Zz
LmggYi9pbmNsdWRlL25ldC9pcF92cy5oDQotLS0gYS9pbmNsdWRlL25ldC9p
cF92cy5oCTIwMDQtMTAtMjkgMDA6MTU6MDcgKzA4OjAwDQorKysgYi9pbmNs
dWRlL25ldC9pcF92cy5oCTIwMDQtMTAtMjkgMDA6MTU6MDcgKzA4OjAwDQpA
QCAtOCw3ICs4LDcgQEANCiANCiAjaW5jbHVkZSA8YXNtL3R5cGVzLmg+CQkv
KiBGb3IgX191WFggdHlwZXMgKi8NCiANCi0jZGVmaW5lIElQX1ZTX1ZFUlNJ
T05fQ09ERQkweDAxMDIwMA0KKyNkZWZpbmUgSVBfVlNfVkVSU0lPTl9DT0RF
CTB4MDEwMjAxDQogI2RlZmluZSBOVkVSU0lPTih2ZXJzaW9uKQkJCVwNCiAJ
KHZlcnNpb24gPj4gMTYpICYgMHhGRiwJCQlcDQogCSh2ZXJzaW9uID4+IDgp
ICYgMHhGRiwJCQlcDQo=
---1463811584-128716279-1098980487=:5836--
