From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next] nfp: add VLAN filtering support
Date: Thu, 15 Jun 2017 12:50:57 +0000
Message-ID: <BLUPR0701MB2004A321103E707B6F6A63918DC00@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <20170615062307.10153-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "oss-drivers@netronome.com" <oss-drivers@netronome.com>,
        =?utf-8?B?UGFibG8gQ2FzY8Ozbg==?= <pablo.cascon@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0074.outbound.protection.outlook.com ([104.47.42.74]:50400
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751955AbdFOMu7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Jun 2017 08:50:59 -0400
In-Reply-To: <20170615062307.10153-1-jakub.kicinski@netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBQYWJsbyBDYXNjw7NuIDxwYWJsby5jYXNjb25AbmV0cm9ub21lLmNvbT4NCj4gDQo+
IEFkZCBnZW5lcmFsIHVzZSBwZXItdk5JQyBtYWlsYm94IGFyZWEgYW5kIHVzZSBpdCBmb3IgVkxB
TiBmaWx0ZXJpbmcgc3VwcG9ydC4NCj4gSW5pdGlhbGx5IHByb3RvIGlzIGhhcmRjb2RlZCB0byA4
MDIuMXEuDQo+IA0KLi4uDQo+ICtzdGF0aWMgaW50DQo+ICtuZnBfbmV0X3ZsYW5fcnhfYWRkX3Zp
ZChzdHJ1Y3QgbmV0X2RldmljZSAqbmV0ZGV2LCBfX2JlMTYgcHJvdG8sIHUxNg0KPiArdmlkKSB7
DQo+ICsJc3RydWN0IG5mcF9uZXQgKm5uID0gbmV0ZGV2X3ByaXYobmV0ZGV2KTsNCj4gKw0KPiAr
CS8qIFByaW9yaXR5IHRhZ2dlZCBwYWNrZXRzIHdpdGggdmxhbiBpZCAwIGFyZSBwcm9jZXNzZWQg
YnkgdGhlDQo+ICsJICogTkZQIGFzIHVudGFnZ2VkIHBhY2tldHMNCj4gKwkgKi8NCj4gKwlpZiAo
IXZpZCkNCj4gKwkJcmV0dXJuIDA7DQo+ICsNCj4gKwlubl93cml0ZXcobm4sIE5GUF9ORVRfQ0ZH
X1ZMQU5fRklMVEVSX1ZJRCwgdmlkKTsNCj4gKwlubl93cml0ZXcobm4sIE5GUF9ORVRfQ0ZHX1ZM
QU5fRklMVEVSX1BST1RPLCBFVEhfUF84MDIxUSk7DQoNCklmIGl0J3MgaGFyZC1jb2RlZCwgZG9u
J3QgeW91IHdhbnQgdG8gZmFpbCB0aGUgcmVxdWVzdCBpbiBjYXNlIHByb3RvIGlzIGRpZmZlcmVu
dD8NCg==
