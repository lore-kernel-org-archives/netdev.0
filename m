From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: [PATCH net-next] net: filter: remove unused variable and fix
 warning
Date: Mon, 30 Oct 2017 21:13:28 +0000
Message-ID: <975C6474-B2CA-4AA3-B3C3-66CD41A72F36@fb.com>
References: <20171030204647.854-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "oss-drivers@netronome.com" <oss-drivers@netronome.com>,
        "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:60286 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752402AbdJ3VNt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 17:13:49 -0400
In-Reply-To: <20171030204647.854-1-jakub.kicinski@netronome.com>
Content-Language: en-US
Content-ID: <EDA117C26CA7E84B850BFCFC6D7D4318@namprd15.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

R29vZCBjYXRjaCwgdGhhbmtzIQ0KDQpPbiAxMC8zMC8xNywgMTo0NyBQTSwgIkpha3ViIEtpY2lu
c2tpIiA8amFrdWIua2ljaW5za2lAbmV0cm9ub21lLmNvbT4gd3JvdGU6DQoNCiAgICBicGZfZ2V0
c29ja29wdCBicGYgY2FsbCBzZXRzIHRoZSByZXQgdmFyaWFibGUgdG8gemVybyBhbmQNCiAgICBu
ZXZlciBjaGFuZ2VzIGl0LiAgV2hhdCdzIHdvcnNlIGluIGNhc2UgQ09ORklHX0lORVQgaXMNCiAg
ICBub3Qgc2VsZWN0ZWQgdGhlIHZhcmlhYmxlIGlzIGNvbXBsZXRlbHkgdW51c2VkIGdlbmVyYXRp
bmcNCiAgICBhIHdhcm5pbmcuDQogICAgDQogICAgU2lnbmVkLW9mZi1ieTogSmFrdWIgS2ljaW5z
a2kgPGpha3ViLmtpY2luc2tpQG5ldHJvbm9tZS5jb20+DQogICAgUmV2aWV3ZWQtYnk6IFF1ZW50
aW4gTW9ubmV0IDxxdWVudGluLm1vbm5ldEBuZXRyb25vbWUuY29tPg0KDQpBY2tlZC1ieTogTGF3
cmVuY2UgQnJha21vIDxicmFrbW9AZmIuY29tPg0KICAgIC0tLQ0KICAgICBuZXQvY29yZS9maWx0
ZXIuYyB8IDMgKy0tDQogICAgIDEgZmlsZSBjaGFuZ2VkLCAxIGluc2VydGlvbigrKSwgMiBkZWxl
dGlvbnMoLSkNCiAgICANCiAgICBkaWZmIC0tZ2l0IGEvbmV0L2NvcmUvZmlsdGVyLmMgYi9uZXQv
Y29yZS9maWx0ZXIuYw0KICAgIGluZGV4IDcyMWMzMDg4OTAzMy4uYTAxMTIxNjhkNmY5IDEwMDY0
NA0KICAgIC0tLSBhL25ldC9jb3JlL2ZpbHRlci5jDQogICAgKysrIGIvbmV0L2NvcmUvZmlsdGVy
LmMNCiAgICBAQCAtMzI4OCw3ICszMjg4LDYgQEAgQlBGX0NBTExfNShicGZfZ2V0c29ja29wdCwg
c3RydWN0IGJwZl9zb2NrX29wc19rZXJuICosIGJwZl9zb2NrLA0KICAgICAJICAgaW50LCBsZXZl
bCwgaW50LCBvcHRuYW1lLCBjaGFyICosIG9wdHZhbCwgaW50LCBvcHRsZW4pDQogICAgIHsNCiAg
ICAgCXN0cnVjdCBzb2NrICpzayA9IGJwZl9zb2NrLT5zazsNCiAgICAtCWludCByZXQgPSAwOw0K
ICAgICANCiAgICAgCWlmICghc2tfZnVsbHNvY2soc2spKQ0KICAgICAJCWdvdG8gZXJyX2NsZWFy
Ow0KICAgIEBAIC0zMzA4LDcgKzMzMDcsNyBAQCBCUEZfQ0FMTF81KGJwZl9nZXRzb2Nrb3B0LCBz
dHJ1Y3QgYnBmX3NvY2tfb3BzX2tlcm4gKiwgYnBmX3NvY2ssDQogICAgIAl9IGVsc2Ugew0KICAg
ICAJCWdvdG8gZXJyX2NsZWFyOw0KICAgICAJfQ0KICAgIC0JcmV0dXJuIHJldDsNCiAgICArCXJl
dHVybiAwOw0KICAgICAjZW5kaWYNCiAgICAgZXJyX2NsZWFyOg0KICAgICAJbWVtc2V0KG9wdHZh
bCwgMCwgb3B0bGVuKTsNCiAgICAtLSANCiAgICAyLjE0LjENCiAgICANCiAgICANCg0K
