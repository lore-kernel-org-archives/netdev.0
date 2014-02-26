From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: shutdown()'s 'how' parameter doesn't seem to be used correctly
Date: Wed, 26 Feb 2014 17:10:03 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6CBEBC@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6CB847@AcuExch.aculab.com>
 <1393432763.2316.149.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49340 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752660AbaBZRLJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Feb 2014 12:11:09 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 18788-07 for <netdev@vger.kernel.org>;
 Wed, 26 Feb 2014 17:11:07 +0000 (GMT)
In-Reply-To: <1393432763.2316.149.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IA0KPiBPbiBXZWQsIDIwMTQtMDItMjYgYXQgMTU6MTggKzAwMDAs
IERhdmlkIExhaWdodCB3cm90ZToNCj4gPiBBRkFJQ1QgdXNlcnNwYWNlIGNhbGxzIHNodXRkb3du
KHNvY2ssIGhvdykgd2l0aCAnaG93JyBzZXQgdG8gb25lIG9mIFNIVVRfUkQgKDApLA0KPiA+IFNI
VVRfV1IgKDEpIG9yIFNIVVRfUkRXUigyKS4NCj4gPg0KPiA+IFRoZSBrZXJuZWwgY29kZSB0eXBp
Y2FsbHkgd2FudHMgdGhlIGJpdG1hc2sgb2YgUkNWX1NIVVRET1dOICgxKSB8IFNFTkRfU0hVVERP
V04gKDIpLg0KPiA+IElmIHlvdSBsb29rIGF0IHRoZSBhZl91bml4LmMgdW5peF9zaHV0ZG93bigp
IHRoZXJlIGlzIGEgY29tbWVudCB3aGVyZSBpdA0KPiA+IGFkZCdzIG9uZSBpbiBvcmRlciB0byBk
byB0aGUgY29udmVyc2lvbi4NCj4gPg0KPiA+IEJ1dCBJIGNhbid0IGZpbmQgdGhlIGNvbnZlcnNp
b24gYmVmb3JlIHRjcF9zaHV0ZG93bigpIG9yIHNjdHBfc2h1dGRvd24oKQ0KPiA+IGNoZWNrcyBm
b3IgJ2hvdyAmIFNFTkRfU0hVVERPV04nLg0KPiA+IFdoaWNoIGltcGxpZXMgdGhhdCBzaHV0ZG93
bihzb2NrLCBTSFVUX1dSKSBkb2Vzbid0IHdvcmsuDQo+ID4NCj4gPiBXaGF0IGhhdmUgSSBtaXNz
ZWQ/DQo+ID4gU2hvdWxkIEkgYmUgcGFzc2luZyAyIG9yIDMgdG8gYSBkaXJlY3QgY2FsbCB0byBz
b2NrLT5vcHMtPnNodXRkb3duKCk/DQo+ID4gKFdlIGN1cnJlbnRseSBwYXNzIDIgLSB3aGljaCBk
b2VzIG91dHdhcmQgZGlzY29ubmVjdCBhbnl3YXkpLg0KPiANCj4gVGFrZSBhIGxvb2sgYXQgaW5l
dF9zaHV0ZG93bigpDQoNClRoYW5rcyAtIHRoZSBsYWNrIG9mICdncmVwLWZyaWVuZGx5JyBzdHJ1
Y3R1cmUgbWVtYmVyIG5hbWVzIG1ha2VzDQpjaGFzaW5nIHRocm91Z2ggdGhpcyBjb2RlIGhhcmQg
d29yay4NCg0KCURhdmlkDQoNCg0K
