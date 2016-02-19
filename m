From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH V2 net-next 2/3] lan78xx: add ethtool set & get pause
 functions
Date: Fri, 19 Feb 2016 00:16:03 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D404B389F@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D404B37B5@CHN-SV-EXMX02.mchp-main.com>
	 <1455839111.2794.51.camel@decadent.org.uk>
	 <9235D6609DB808459E95D78E17F2E43D404B3871@CHN-SV-EXMX02.mchp-main.com>
 <1455840387.2794.59.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>
To: <ben@decadent.org.uk>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:8033 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1427083AbcBSAQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 19:16:06 -0500
In-Reply-To: <1455840387.2794.59.camel@decadent.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IEJlbiwgdGhhbmtzIGZvciBjb21tZW50cy4NCj4gPiBIb3cgYWJvdXQgY29tbWVudCBpbiBp
bmNsdWRlL3VhcGkvbGludXgvZXRodG9vbC5oPw0KPiA+IEl0IHNheXMNCj4gPiAqKiBzdHJ1Y3Qg
ZXRodG9vbF9wYXVzZXBhcmFtIC0gRXRoZXJuZXQgcGF1c2UgKGZsb3cgY29udHJvbCkgcGFyYW1l
dGVycw0KPiA+IC4uLg0KPiA+ICogSWYgQGF1dG9uZWcgaXMgbm9uLXplcm8sIHRoZSBNQUMgaXMg
Y29uZmlndXJlZCB0byBzZW5kIGFuZC9vcg0KPiA+ICogcmVjZWl2ZSBwYXVzZSBmcmFtZXMgYWNj
b3JkaW5nIHRvIHRoZSByZXN1bHQgb2YgYXV0b25lZ290aWF0aW9uLg0KPiA+DQo+ID4gRG9lc24n
dCB0aGlzIG1lYW4gZ2V0X3BhdXNlcGFyYW0oKSByZXR1cm5zIHBhdXNlIHNldHRpbmdzIGJhc2Vk
IG9uDQo+ID4gUmVzdWx0IG9mIGF1dG9uZWdvdGF0aW9uPyBOb3QgbWFudWFsIHNldHRpbmdzIG9m
IHJ4X3BhcmFtICYgdHhfcGFyYW0/DQo+IA0KPiBObywgZ2V0X3BhdXNlcGFyYW0gc2hvdWxkIHJl
dHVybiB0aGUgc2FtZSBzZXR0aW5ncyB0aGF0IHdlcmUgcGFzc2VkIHRvDQo+IHRoZSBsYXN0IHNl
dF9wYXVzZXBhcmFtLg0KPiANCj4gQmVuLg0KDQpJIHVzZWQgZHJpdmVycy9uZXQvZXRoZXJuZXQv
aW50ZWwvZTEwMDBlIGRyaXZlciBhcyByZWZlcmVuY2UuDQpJdCdzIGltcGxlbWVudGF0aW9uIGFs
c28gcmV0dXJucyBzdGF0dXMgdXBkYXRlZCBhZnRlciBhdXRvbmVnb3RpYXRpb24uDQpMb29rIGlu
dG8gd3Jvbmcgb25lPw0KDQpXb29qdW5nDQo=
