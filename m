From: <Somnath.Kotur@Emulex.Com>
Subject: RE: [PATCH net-next 3/5] be2net: Fix to apply duplex value as
 unknown when link is down.
Date: Thu, 26 Apr 2012 23:42:38 -0700
Message-ID: <3367B80B08154D42A3B2BC708B5D41F6440F8979D5@EXMAIL.ad.emulex.com>
References: <cf78444f-636f-44c5-beb7-5626b8a3df17@exht1.ad.emulex.com>
 <1335461076.2712.20.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>
To: <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:2239 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750864Ab2D0GnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 02:43:01 -0400
In-Reply-To: <1335461076.2712.20.camel@bwh-desktop.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ID4gSSBkb24ndCBzZWUgYW55IHByb2JsZW0gd2l0aCByZXBvcnRpbmcgZnVsbC1kdXBsZXggYWxs
IHRoZSB0aW1lIGlmIHlvdSBkb24ndA0KPiBzdXBwb3J0IGFueSBoYWxmLWR1cGxleCBsaW5rIG1v
ZGVzLiAgQnV0IHdlIGRvbid0IHlldCBoYXZlIGNvbnNpc3RlbmN5DQo+IGJldHdlZW4gZHJpdmVy
cyBpbiBzcGVlZC9kdXBsZXggcmVwb3J0aW5nIHdoaWxlIHRoZSBsaW5rIGlzIGRvd24sIHNvIEkg
d29uJ3QNCj4gaW5zaXN0IHRoYXQgdGhhdCBpcyB0aGUgcmlnaHQgdGhpbmcgdG8gZG8uDQo+IA0K
PiBIb3dldmVyIHlvdSBzaG91bGQgdXNlIERVUExFWF9VTktOT1dOIHJhdGhlciB0aGFuIC0xLg0K
PiANCj4gQmVuLg0KDQpZZXMsIEFncmVlZC4gVGhhbmsgeW91IGZvciB5b3VyIHJldmlldy9zdWdn
ZXN0aW9uLg0KDQpXaWxsIG1ha2UgdGhlIGNoYW5nZSBhbmQgcmUtcG9zdC4NCg0KLVNvbS4NCg0K
PiAtLQ0KPiBCZW4gSHV0Y2hpbmdzLCBTdGFmZiBFbmdpbmVlciwgU29sYXJmbGFyZSBOb3Qgc3Bl
YWtpbmcgZm9yIG15IGVtcGxveWVyOw0KPiB0aGF0J3MgdGhlIG1hcmtldGluZyBkZXBhcnRtZW50
J3Mgam9iLg0KPiBUaGV5IGFza2VkIHVzIHRvIG5vdGUgdGhhdCBTb2xhcmZsYXJlIHByb2R1Y3Qg
bmFtZXMgYXJlIHRyYWRlbWFya2VkLg0KDQo=
