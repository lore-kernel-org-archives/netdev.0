From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Fri, 28 Feb 2014 11:47:27 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6CDBD9@AcuExch.aculab.com>
References: <201312270037.15822.sergei.shtylyov@cogentembedded.com>
	<52DCE9E4.7010209@pengutronix.de>	<52E3148E.2010608@cogentembedded.com>
	<52FCB6C5.6020001@pengutronix.de>	<53069445.80408@cogentembedded.com>
	<5310521E.6000708@pengutronix.de>	<53107007.7050802@cogentembedded.com>
	<531074F5.8090702@pengutronix.de>
 <CAMuHMdUuaX0pGmdOuJ9CJwj-ZTYo4PqTtZmYHh8swamQ754s2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Pavel Kiryukhin <vksavl@gmail.com>
To: 'Geert Uytterhoeven' <geert@linux-m68k.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdUuaX0pGmdOuJ9CJwj-ZTYo4PqTtZmYHh8swamQ754s2A@mail.gmail.com>
Content-Language: en-US
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogR2VlcnQgVXl0dGVyaG9ldmVuDQo+IE9uIEZyaSwgRmViIDI4LCAyMDE0IGF0IDEyOjM3
IFBNLCBNYXJjIEtsZWluZS1CdWRkZSA8bWtsQHBlbmd1dHJvbml4LmRlPiB3cm90ZToNCj4gPj4+
IEEgMzIgYml0IHJlYWQvbW9kaWZ5L3dyaXRlIGlzIGEgc3RhbmRhcmQgb3BlcmF0aW9uLCBub3Ro
aW5nIHNwZWNpYWwsIG5vDQo+ID4+PiBuZWVkIHRvIHdvcnJ5IGFib3V0IGJ5dGUgc3dhcHBpbmcg
b3IgYW55dGhpbmcgbGlrZSB0aGlzLg0KPiA+Pg0KPiA+PiAgICBPaCwgcmVhbGx5PyA4LSkNCj4g
Pj4gICAgRG9uJ3QgeW91IGtub3cgdGhhdCByZWFkW2J3bHFdKCkgYXNzdW1lIGxpdHRsZS1lbmRp
YW4gbWVtb3J5IGxheW91dA0KPiA+PiBhbmQgdG8gcmVhZCBmcm9tIGJpZy1lbmRpYW4gMzItYml0
IHJlZ2lzdGVyIG9uZSBub3JtYWxseSBuZWVkcyByZWFkbF9iZSgpPw0KPiA+DQo+ID4gSSBhc3N1
bWUgeW91IGFyZSBvbiBsaXR0bGUgZW5kaWFuIEFSTSBvbmx5IChmb3Igbm93KS4NCj4gPg0KPiA+
IElmIHlvdSB1c2UgYSBzdGFuZGFyZCAzMiBiaXQgcmVhZCwgdGhlbiBtb2RpZnkgdGhlIGNvcnJl
Y3QgYml0cyBpbiB0aGF0DQo+ID4gMzIgYml0IHdvcmQgYW5kIHdyaXRlIGl0IGJhY2ssIHdpdGgg
dGhlIGNvcnJlc3BvbmRpbmcgMzIgYml0IHdyaXRlDQo+ID4gZXZlcnl0aGluZyBzaG91bGQgYmUg
ZmluZS4gRm9yIHRoaXMgdXNlY2FzZSB5b3UganVzdCBoYXZlIHlvIGZpZ3VyZSBvdXQNCj4gPiB3
aGljaCAyNCBvZiB0aGUgMzIgYml0IGFyZSB0aGUgb25lIHlvdSBoYXZlIHRvIGNoYW5nZSBhbmQg
d2hpY2ggYXJlIHRoZQ0KPiA+IDggdGhhdCBtdXN0IG5vdCBiZSBtb2RpZmllZC4NCj4gPg0KPiA+
IExvb2tpbmcgYXQgdGhlIHJlZ2lzdGVyIGxheW91dDoNCj4gPg0KPiA+PiArICAgICB1OCBiY3Jb
M107ICAgICAgLyogQml0IENvbmZpZ3VyYXRpb24gUmVnaXN0ZXIgKi8NCj4gPj4gKyAgICAgdTgg
Y2xrcjsgICAgICAgIC8qIENsb2NrIFNlbGVjdCBSZWdpc3RlciAqLw0KPiA+DQo+ID4gSSB0aGlu
ayBjbGtyIHdvdWxkIGJlIHRoZSBsb3dlc3QgOCBiaXQgYW5kIGJjcltdIGFyZSB0aGUgdXBwZXIg
MjQuDQo+IA0KPiBUaGF0IHdvdWxkIGJlIHRoZSBvdXRjb21lIG9uIGJpZyBlbmRpYW4gOy0pDQoN
Ckxvb2tzIHRvIG1lIGFzIHRob3VnaCBpdCBzaG91bGQgYmUgZGVmaW5lZCBhcyBhIDMyYml0IGZp
ZWxkIGFuZCB0aGVuDQp0aGUgYXBwcm9wcmlhdGUgYml0IGRlZmluaXRpb25zIGFuZCBtYXNrcyBh
cHBsaWVkLg0KDQoJRGF2aWQNCg0K
