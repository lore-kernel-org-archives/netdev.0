From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH iproute2 1/3] tc: fix compilation warning on 32bits arch
Date: Tue, 21 Apr 2015 16:22:32 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB2312E@AcuExch.aculab.com>
References: <1429632397-11122-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Nicolas Dichtel' <nicolas.dichtel@6wind.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.183]:60846 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932740AbbDUQXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 12:23:52 -0400
In-Reply-To: <1429632397-11122-1-git-send-email-nicolas.dichtel@6wind.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogTmljb2xhcyBEaWNodGVsDQo+IFNlbnQ6IDIxIEFwcmlsIDIwMTUgMTc6MDcNCj4gVGhl
IHdhcm5pbmcgd2FzOg0KPiBtX3NpbXBsZS5jOiBJbiBmdW5jdGlvbiBwYXJzZV9zaW1wbGU6DQo+
IG1fc2ltcGxlLmM6MTQyOjQ6IHdhcm5pbmc6IGZvcm1hdCAlbGQgZXhwZWN0cyBhcmd1bWVudCBv
ZiB0eXBlIGxvbmcgaW50LCBidXQgYXJndW1lbnQgMyBoYXMgdHlwZQ0KPiBzaXplX3QgWy1XZm9y
bWF0XQ0KPiANCj4gVXNlZnVsIHRvIGJlIGFibGUgdG8gY29tcGlsZSB3aXRoIC1XZXJyb3IuDQo+
IA0KPiBTaWduZWQtb2ZmLWJ5OiBOaWNvbGFzIERpY2h0ZWwgPG5pY29sYXMuZGljaHRlbEA2d2lu
ZC5jb20+DQo+IC0tLQ0KPiAgdGMvbV9zaW1wbGUuYyB8IDIgKy0NCj4gIDEgZmlsZSBjaGFuZ2Vk
LCAxIGluc2VydGlvbigrKSwgMSBkZWxldGlvbigtKQ0KPiANCj4gZGlmZiAtLWdpdCBhL3RjL21f
c2ltcGxlLmMgYi90Yy9tX3NpbXBsZS5jDQo+IGluZGV4IDg2NjU1MmY1NTliMy4uM2I2ZDdiZWI3
NjljIDEwMDY0NA0KPiAtLS0gYS90Yy9tX3NpbXBsZS5jDQo+ICsrKyBiL3RjL21fc2ltcGxlLmMN
Cj4gQEAgLTEzOSw3ICsxMzksNyBAQCBwYXJzZV9zaW1wbGUoc3RydWN0IGFjdGlvbl91dGlsICph
LCBpbnQgKmFyZ2NfcCwgY2hhciAqKiphcmd2X3AsIGludCB0Y2FfaWQsDQo+IA0KPiAgCWlmIChz
dHJsZW4oc2ltcGRhdGEpID4gKFNJTVBfTUFYX0RBVEEgLSAxKSkgew0KPiAgCQlmcHJpbnRmKHN0
ZGVyciwgInNpbXBsZTogSWxsZWdhbCBzdHJpbmcgbGVuICVsZCA8JXM+IFxuIiwNCj4gLQkJCXN0
cmxlbihzaW1wZGF0YSksIHNpbXBkYXRhKTsNCj4gKwkJCShsb25nKXN0cmxlbihzaW1wZGF0YSks
IHNpbXBkYXRhKTsNCj4gIAkJcmV0dXJuIC0xOw0KDQpJc24ndCB0aGUgY29ycmVjdCBmaXggdG8g
dXNlICIlenUiID8NCg0KCURhdmlkDQoNCg==
