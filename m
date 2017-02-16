From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next v7 1/2] qed: Add infrastructure for PTP support
Date: Thu, 16 Feb 2017 12:48:44 +0000
Message-ID: <BL2PR07MB23068A1A0E584D18BFC3913F8D5A0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1487147051-14350-1-git-send-email-Yuval.Mintz@cavium.com>
         <1487147051-14350-2-git-send-email-Yuval.Mintz@cavium.com>
 <1487248919.1311.39.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "richardcochran@gmail.com" <richardcochran@gmail.com>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0088.outbound.protection.outlook.com ([104.47.33.88]:29616
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753285AbdBPMst (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:48:49 -0500
In-Reply-To: <1487248919.1311.39.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+ICsvKiBSZWFkIFBoeSBIYXJkd2FyZSBDbG9jayAqLw0KPiA+ICtzdGF0aWMgaW50IHFlZF9w
dHBfaHdfcmVhZF9jYyhzdHJ1Y3QgcWVkX2RldiAqY2RldiwgdTY0ICpwaGNfY3ljbGVzKQ0KPiA+
ICt7DQo+ID4gKwlzdHJ1Y3QgcWVkX2h3Zm4gKnBfaHdmbiA9IFFFRF9MRUFESU5HX0hXRk4oY2Rl
dik7DQo+ID4gKwlzdHJ1Y3QgcWVkX3B0dCAqcF9wdHQgPSBwX2h3Zm4tPnBfcHRwX3B0dDsNCj4g
PiArCXUzMiB0ZW1wID0gMDsNCj4gPiArDQo+ID4gKwl0ZW1wID0gcWVkX3JkKHBfaHdmbiwgcF9w
dHQsIE5JR19SRUdfVFNHRU5fU1lOQ19USU1FX0xTQik7DQo+ID4gKwkqcGhjX2N5Y2xlcyA9IHFl
ZF9yZChwX2h3Zm4sIHBfcHR0LA0KPiBOSUdfUkVHX1RTR0VOX1NZTkNfVElNRV9NU0IpOw0KPiA+
ICsJKnBoY19jeWNsZXMgPDw9IDMyOw0KPiA+ICsJKnBoY19jeWNsZXMgfD0gdGVtcDsNCj4gPiAr
DQo+ID4gKwlyZXR1cm4gMDsNCj4gPiArfQ0KPiANCj4gTFNCIGFuZCBNU0IgYmVpbmcgcmVhZCBu
b24gYXRvbWljYWxseSwgaXQgbG9va3MgbGlrZSB5b3UgY291bGQgaGF2ZSBhbiBlcnJvcg0KPiBv
ZiAoMTw8MzIpIGN5Y2xlcyBoZXJlLg0KPiANCj4gKFlvdSByZWFkIExTQiB2YWx1ZSBjbG9zZSB0
byAweEZGRkZGRkZGIHJpZ2h0IGJlZm9yZSBpdCBjaGFuZ2VzIHRvIDAsIHdoaWxlDQo+IE1TQiBn
b3QgaW5jcmVtZW50ZWQuKQ0KDQpPbmNlIHdlIHJlYWQgdGhlIExTQiwgSFcgbGF0Y2hlcyB0aGUg
TVNCIHVudGlsIGl0J3MgcmVhZC4NClNvIGl0J3Mgbm90IGFuIGlzc3VlIFthbHRob3VnaCBwcm9i
YWJseSB3b3J0aCBhIGNvbW1lbnRdLg0K
