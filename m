From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: RE: [PATCH net-next] bnx2x: handle spurious interrupts
Date: Tue, 2 Apr 2013 05:03:01 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52ABFCCF1@SJEXCHMB10.corp.ad.broadcom.com>
References: <1364729701-18855-1-git-send-email-yuvalmin@broadcom.com>
 <1364747492.3557.62.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2228 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759120Ab3DBFDM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Apr 2013 01:03:12 -0400
In-Reply-To: <1364747492.3557.62.camel@deadeye.wl.decadent.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+ICB2b2lkIGJueDJ4X2ludF9lbmFibGUoc3RydWN0IGJueDJ4ICpicCkNCj4gPiAgew0KPiA+
ICsJYnAtPmZsYWdzIHw9IElOVEVSUlVQVFNfRU5BQkxFRF9GTEFHOw0KPiA+ICsNCj4gDQo+IHdt
YigpOw0KDQpTdXJlLg0KDQo+IA0KPiA+ICAJaWYgKGJwLT5jb21tb24uaW50X2Jsb2NrID09IElO
VF9CTE9DS19IQykNCj4gPiAgCQlibngyeF9oY19pbnRfZW5hYmxlKGJwKTsNCj4gPiAgCWVsc2UN
Cj4gWy4uLl0NCg0KPiA+IC0tLSBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L2Jyb2FkY29tL2JueDJ4
L2JueDJ4X21haW4uYw0KPiA+ICsrKyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2Jyb2FkY29tL2Ju
eDJ4L2JueDJ4X21haW4uYw0KPiA+IEBAIC04NjYsNiArODY2LDcgQEAgc3RhdGljIHZvaWQgYm54
MnhfaW50X2Rpc2FibGUoc3RydWN0IGJueDJ4ICpicCkNCj4gPiAgCQlibngyeF9oY19pbnRfZGlz
YWJsZShicCk7DQo+ID4gIAllbHNlDQo+ID4gIAkJYm54MnhfaWd1X2ludF9kaXNhYmxlKGJwKTsN
Cj4gDQo+IGZvciAoZWFjaCBpbnRlcnJ1cHQgdmVjdG9yKQ0KPiAJc3luY2hyb25pemVfaXJxKGly
cSk7DQo+IA0KPiA+ICsJYnAtPmZsYWdzICY9IH5JTlRFUlJVUFRTX0VOQUJMRURfRkxBRzsNCj4g
PiAgfQ0KDQpUaGlzIHdhcyBhZGRlZCBtb3N0bHkgZm9yIGNvbXBsZXRlbmVzczsgV2UncmUgdW5h
d2FyZSBvZiBhbnkgcG9zc2libGUgc3B1cmlvdXMgaW50ZXJydXB0IGFmdGVyIA0KaW50ZXJydXB0
cyBhcmUgZGlzYWJsZWQuIFRoZW4gYWdhaW4sIGFzIEknbSBhYm91dCB0byByZS1zZW5kIGEgbW9k
aWZpZWQgdmVyc2lvbiBvZiB0aGlzIHBhdGNoLCBJJ2xsIHByb2JhYmx5DQppbnRyb2R1Y2UgdGhp
cyBjaGFuZ2UgYXMgd2VsbC4NCg0KVGhhbmtzLA0KWXV2YWwNCg==
