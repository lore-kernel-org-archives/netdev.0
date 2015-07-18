From: Johan Schuijt <johan@transip.nl>
Subject: Re: reproducable panic eviction work queue
Date: Sat, 18 Jul 2015 15:28:02 +0000
Message-ID: <22C5EB62-8974-432D-9C3B-45F4E4067A45@transip.nl>
References: <F8D94413-90A2-4F80-AAA2-7A6AB57DF314@transip.nl>
 <1437209795.1026.31.camel@edumazet-glaptop2.roam.corp.google.com>
 <5FD5C17E-B321-404E-80A2-EE46BB8AA746@transip.nl>
 <55AA243D.5020306@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"nikolay@redhat.com" <nikolay@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"fw@strlen.de" <fw@strlen.de>,
	"chutzpah@gentoo.org" <chutzpah@gentoo.org>,
	Robin Geuze <robing@transip.nl>,
	Frank Schreuder <fschreuder@transip.nl>,
	netdev <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0118.outbound.protection.outlook.com ([157.55.234.118]:31452
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751313AbbGRP2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Jul 2015 11:28:08 -0400
In-Reply-To: <55AA243D.5020306@cumulusnetworks.com>
Content-Language: en-US
Content-ID: <54AED697B1716943B4B91ECEC7F71A81@eurprd02.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VGh4IGZvciB5b3VyIGxvb2tpbmcgaW50byB0aGlzIQ0KDQo+IA0KPiBUaGFuayB5b3UgZm9yIHRo
ZSByZXBvcnQsIEkgd2lsbCB0cnkgdG8gcmVwcm9kdWNlIHRoaXMgbG9jYWxseQ0KPiBDb3VsZCB5
b3UgcGxlYXNlIHBvc3QgdGhlIGZ1bGwgY3Jhc2ggbG9nID8NCg0KT2YgY291cnNlLCBwbGVhc2Ug
c2VlIGF0dGFjaGVkIGZpbGUuDQoNCj4gQWxzbyBjb3VsZCB5b3UgdGVzdA0KPiB3aXRoIGEgY2xl
YW4gY3VycmVudCBrZXJuZWwgZnJvbSBMaW51cycgdHJlZSBvciBEYXZlJ3MgLW5ldCA/DQoNCldp
bGwgZG8uDQoNCj4gVGhlc2UgYXJlIGF2YWlsYWJsZSBhdDoNCj4gZ2l0Oi8vZ2l0Lmtlcm5lbC5v
cmcvcHViL3NjbS9saW51eC9rZXJuZWwvZ2l0L3RvcnZhbGRzL2xpbnV4LmdpdA0KPiBnaXQ6Ly9n
aXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvZGF2ZW0vbmV0DQo+IHJlc3Bl
Y3RpdmVseS4NCj4gDQo+IE9uZSBsYXN0IHF1ZXN0aW9uIGhvdyBtYW55IElSUXMgZG8geW91IHBp
biBpLmUuIGhvdyBtYW55IGNvcmVzDQo+IGRvIHlvdSBhY3RpdmVseSB1c2UgZm9yIHJlY2VpdmUg
Pw0KDQpUaGlzIHZhcmllcyBhIGJpdCBhY3Jvc3Mgb3VyIHN5c3RlbXMsIGJ1dCB3ZeKAmXZlIG1h
bmFnZWQgdG8gcmVwcm9kdWNlIHRoaXMgd2l0aCBJUlFzIHBpbm5lZCBvbiBhcyBtYW55IGFzIDIs
NCw4IG9yIDIwIGNvcmVzLg0KDQpJIHdvbuKAmXQgaGF2ZSBhY2Nlc3MgdG8gb3VyIHRlc3Qtc2V0
dXAgdGlsbCBNb25kYXkgYWdhaW4sIHNvIEnigJlsbCBiZSB0ZXN0aW5nIDMgc2NlbmFyaW/igJlz
IHRoZW46DQotIFlvdXIgcGF0Y2gNCi0gTGludXggdHJlZQ0KLSBEYXZl4oCZcyAtbmV0IHRyZWUN
Cg0KSeKAmWxsIG1ha2Ugc3VyZSB0byBrZWVwIHlvdSBwb3N0ZWQgb24gYWxsIHRoZSByZXN1bHRz
IHRoZW4uIFdlIGhhdmUgYSBrZXJuZWwgZHVtcCBvZiB0aGUgcGFuaWMsIHNvIGlmIHlvdSBuZWVk
IG1lIHRvIGV4dHJhY3QgYW55IGRhdGEgZnJvbSB0aGVyZSBqdXN0IGxldCBtZSBrbm93ISAoU29t
ZSBpbnN0cnVjdGlvbnMgbWlnaHQgYmUgbmVlZGVkKQ0KDQotIEpvaGFu
