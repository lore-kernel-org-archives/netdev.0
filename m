From: "Andy Cress" <andy.cress@us.kontron.com>
Subject: RE: [PATCH 4/4] pch_gbe: vlan skb len fix
Date: Tue, 10 Jul 2012 08:25:39 -0700
Message-ID: <40680C535D6FE6498883F1640FACD44D011051C7@ka-exchange-1.kontronamerica.local>
References: <40680C535D6FE6498883F1640FACD44D010BFC0E@ka-exchange-1.kontronamerica.local> <1341866003.2535.60.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.kontron.com ([209.118.138.70]:47666 "EHLO
	mail.us.kontron.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753729Ab2GJPZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 11:25:41 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1341866003.2535.60.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VGhhdCdzIGEgZ29vZCBpZGVhLiAgUmVtb3ZpbmcgdGhlIGNoZWNrIGlzIHNp
bXBsZXIsIHNpbXBsZXIgaXMgYmV0dGVyLg0KDQpZZXMsIGFwcGFyZW50bHkg
SSBkbyBuZWVkIHRvIHJlc3VibWl0IHdpdGggYSBkaWZmZXJlbnQgZW1haWwg
Y2xpZW50Lg0KDQpBbmR5DQoNCi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0t
DQpGcm9tOiBCZW4gSHV0Y2hpbmdzIFttYWlsdG86Ymh1dGNoaW5nc0Bzb2xh
cmZsYXJlLmNvbV0gDQpTZW50OiBNb25kYXksIEp1bHkgMDksIDIwMTIgNDoz
MyBQTQ0KVG86IEFuZHkgQ3Jlc3MNCkNjOiBuZXRkZXZAdmdlci5rZXJuZWwu
b3JnDQpTdWJqZWN0OiBSZTogW1BBVENIIDQvNF0gcGNoX2diZTogdmxhbiBz
a2IgbGVuIGZpeA0KDQpPbiBNb24sIDIwMTItMDctMDkgYXQgMDY6MzAgLTA3
MDAsIEFuZHkgQ3Jlc3Mgd3JvdGU6DQo+IEF1dGhvcjogVmVhY2VzbGF2IEZh
bGljbyA8dmZhbGljb0ByZWRoYXQuY29tPg0KPiBEYXRlOiAgIFR1ZSBBcHIg
MTAgMDg6MTQ6MTcgMjAxMiArMDIwMA0KPiANCj4gICAgIHBjaF9nYmU6IGNv
cnJlY3RseSB2ZXJpZnkgc2tiLT5sZW4gaW4gdmxhbiBjYXNlDQo+ICAgICAg
ICAgICAgICB0byBhdm9pZCBib2d1cyB0cmFuc2ZlciBsZW5ndGggZXJyb3Jz
Lg0KDQpUaGlzIGNoZWNrIHNob3VsZG4ndCBiZSBuZWNlc3NhcnkgYXQgYWxs
LiAgTWF5YmUgeW91IHNob3VsZCByZW1vdmUgaXQNCmluc3RlYWQgb2YgY29y
cmVjdGluZyB0aGUgY2hlY2s/DQoNCkFsc28sIHRoZXNlIHBhdGNoZXMgYXJl
IHdvcmQtd3JhcHBlZCwgYW5kIHdvdWxkIG5vdCBiZSBhcHBsaWNhYmxlIGlu
DQp0aGlzIGZvcm0uICBTZWUgRG9jdW1lbnRhdGlvbi9lbWFpbC1jbGllbnRz
LnR4dC4NCg0KQmVuLg0K
