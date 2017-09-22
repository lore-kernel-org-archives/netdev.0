From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH] hv_netvsc:  make const array ver_list static, reduces
 object code size
Date: Fri, 22 Sep 2017 16:00:37 +0000
Message-ID: <MWHPR21MB04795E0C01527E2D096E6B05CA670@MWHPR21MB0479.namprd21.prod.outlook.com>
References: <20170922155023.15821-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>,
        KY Srinivasan <kys@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170922155023.15821-1-colin.king@canonical.com>
Content-Language: en-US
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogQ29saW4gS2luZyBbbWFp
bHRvOmNvbGluLmtpbmdAY2Fub25pY2FsLmNvbV0NCj4gU2VudDogRnJpZGF5LCBTZXB0ZW1iZXIg
MjIsIDIwMTcgODo1MCBBTQ0KPiBUbzogS1kgU3Jpbml2YXNhbiA8a3lzQG1pY3Jvc29mdC5jb20+
OyBIYWl5YW5nIFpoYW5nDQo+IDxoYWl5YW5nekBtaWNyb3NvZnQuY29tPjsgU3RlcGhlbiBIZW1t
aW5nZXIgPHN0aGVtbWluQG1pY3Jvc29mdC5jb20+Ow0KPiBkZXZlbEBsaW51eGRyaXZlcnByb2pl
Y3Qub3JnOyBuZXRkZXZAdmdlci5rZXJuZWwub3JnDQo+IENjOiBrZXJuZWwtamFuaXRvcnNAdmdl
ci5rZXJuZWwub3JnOyBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnDQo+IFN1YmplY3Q6IFtQ
QVRDSF0gaHZfbmV0dnNjOiBtYWtlIGNvbnN0IGFycmF5IHZlcl9saXN0IHN0YXRpYywgcmVkdWNl
cw0KPiBvYmplY3QgY29kZSBzaXplDQo+IA0KPiBGcm9tOiBDb2xpbiBJYW4gS2luZyA8Y29saW4u
a2luZ0BjYW5vbmljYWwuY29tPg0KPiANCj4gRG9uJ3QgcG9wdWxhdGUgY29uc3QgYXJyYXkgdmVy
X2xpc3Qgb24gdGhlIHN0YWNrLCBpbnN0ZWFkIG1ha2UgaXQNCj4gc3RhdGljLiBNYWtlcyB0aGUg
b2JqZWN0IGNvZGUgc21hbGxlciBieSBvdmVyIDQwMCBieXRlczoNCj4gDQo+IEJlZm9yZToNCj4g
ICAgdGV4dAkgICBkYXRhCSAgICBic3MJICAgIGRlYwkgICAgaGV4CWZpbGVuYW1lDQo+ICAgMTg0
NDQJICAgMzE2OAkgICAgMzIwCSAgMjE5MzIJICAgNTVhYw0KPiAJZHJpdmVycy9uZXQvaHlwZXJ2
L25ldHZzYy5vDQo+IA0KPiBBZnRlcjoNCj4gICAgdGV4dAkgICBkYXRhCSAgICBic3MJICAgIGRl
YwkgICAgaGV4CWZpbGVuYW1lDQo+ICAgMTc5NTAJICAgMzIyNAkgICAgMzIwCSAgMjE0OTQJICAg
NTNmNg0KPiAJZHJpdmVycy9uZXQvaHlwZXJ2L25ldHZzYy5vDQo+IA0KPiAoZ2NjIDYuMy4wLCB4
ODYtNjQpDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBDb2xpbiBJYW4gS2luZyA8Y29saW4ua2luZ0Bj
YW5vbmljYWwuY29tPg0KPiAtLS0NCg0KUmV2aWV3ZWQtYnk6IEhhaXlhbmcgWmhhbmcgPGhhaXlh
bmd6QG1pY3Jvc29mdC5jb20+DQoNCg0K
