From: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Subject: RE: [PATCH] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Wed, 2 Mar 2016 08:41:40 +0000
Message-ID: <SG2PR06MB1038AC389CDB35916408A5D6C3BC0@SG2PR06MB1038.apcprd06.prod.outlook.com>
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <56D5FE8E.1090400@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-renesas-soc@vger.kernel.org"
	<linux-renesas-soc@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"geert+renesas@glider.be" <geert+renesas@glider.be>,
	Chris Paterson <Chris.Paterson2@renesas.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"corbet@lwn.net" <corbet@lwn.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <56D5FE8E.1090400@pengutronix.de>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SGkgTWFyYywNCg0KVGhhbmtzIGZvciB0aGUgcmV2aWV3Lg0KDQo+IE9uIDAzLzAxLzIwMTYgMTA6
MzQgQU0sIFJhbWVzaCBTaGFubXVnYXN1bmRhcmFtIHdyb3RlOg0KPiA+IFRoaXMgcGF0Y2ggYWRk
cyBzdXBwb3J0IGZvciB0aGUgQ0FOIEZEIGNvbnRyb2xsZXIgZm91bmQgaW4gUmVuZXNhcw0KPiA+
IFItQ2FyIFNvQ3MuIFRoZSBjb250cm9sbGVyIG9wZXJhdGVzIGluIENBTiBGRCBtb2RlIGJ5IGRl
ZmF1bHQuIFR3bw0KPiA+IHRlc3QgbW9kZXMgYXJlIGF2YWlsYWJsZSBhbmQgY2FuIGJlIGVuYWJs
ZWQgYnkgdGhlDQo+ID4gInJjYXJfY2FuZmQudGVzdG1vZGUiIG1vZHVsZSBwYXJhbWV0ZXIuIFJl
ZmVyIHRvIERvY3VtZW50YXRpb24va2VybmVsLQ0KPiBwYXJhbWV0ZXJzLnR4dC4NCj4gDQo+IElz
IHRoZSBjaGFubmVsIGxvb3BiYWNrIG1vZGUgY29uZmlndXJhYmxlIHBlciBjaGFubmVsPyBJZiBz
bywgcGxlYXNlDQo+IHJlbW92ZSB0aGUgbW9kdWxlIHBhcmFtZXRlciBhbmQgbWFrZSB1c2Ugb2Yg
Q0FOX0NUUkxNT0RFX0xPT1BCQUNLIHRvDQo+IGNvbmZpZ3VyZSBpdC4NCg0KVGhlIGxvb3BiYWNr
IHNldHRpbmcgaXMgbm90IHRydWx5IGEgcGVyIGNoYW5uZWwgYXR0cmlidXRlLiBJdCByZXF1aXJl
cyB0b3VjaGluZyBSeCBydWxlcyB3aGljaCBjYW4gYmUgZG9uZSBvbmx5IHdoZW4gdGhlIGNvbnRy
b2xsZXIncyBnbG9iYWwgc3RhdGUgaXMgcmVzZXQgKGR1cmluZyBwcm9iZSkuIENBTl9DVFJMTU9E
RV9MT09QQkFDSyBjb25maWcgb3B0aW9uIGlzIHBvc3NpYmxlIG9ubHkgdGhyb3VnaCAubmRvX29w
ZW4gb2YgdGhhdCBjaGFubmVsIGJ1dCB0aGUgZ2xvYmFsIGNvbnRyb2xsZXIgc3RhdGUgbmVlZHMg
dG8gYmUgb3BlcmF0aW9uYWwgYnkgdGhpcyB0aW1lLiBBcyBpdCBpcyBhIGdsb2JhbCBhdHRyaWJ1
dGUgJiBmb3IgdGhlIGFib3ZlIHJlYXNvbiwgSSBjaG9vc2UgdGhlIG1vZHVsZSBvcHRpb24uDQoN
Cj4gDQo+ID4gQ0FOIEZEIG1vZGUgc3VwcG9ydHMgYm90aCBDbGFzc2ljYWwgQ0FOICYgQ0FOIEZE
IGZyYW1lIGZvcm1hdHMuIFRoZQ0KPiA+IGNvbnRyb2xsZXIgc3VwcG9ydHMgSVNPIDExODk4LTE6
MjAxNSBDQU4gRkQgZm9ybWF0IG9ubHkuDQo+ID4NCj4gPiBUaGlzIGNvbnRyb2xsZXIgc3VwcG9y
dHMgdHdvIGNoYW5uZWxzIGFuZCB0aGUgZHJpdmVyIGNhbiBlbmFibGUgZWl0aGVyDQo+ID4gb3Ig
Ym90aCBvZiB0aGUgY2hhbm5lbHMuDQo+ID4NCj4gPiBEcml2ZXIgdXNlcyBSeCBGSUZPcyAob25l
IHBlciBjaGFubmVsKSBmb3IgcmVjZXB0aW9uICYgQ29tbW9uIEZJRk9zDQo+ID4gKG9uZSBwZXIg
Y2hhbm5lbCkgZm9yIHRyYW5zbWlzc2lvbi4gUnggZmlsdGVyIHJ1bGVzIGFyZSBjb25maWd1cmVk
IHRvDQo+ID4gdGhlIG1pbmltdW0gKG9uZSBwZXIgY2hhbm5lbCkgYW5kIGl0IGFjY2VwdHMgU3Rh
bmRhcmQsIEV4dGVuZGVkLCBEYXRhDQo+ID4gJiBSZW1vdGUgRnJhbWUgY29tYmluYXRpb25zLg0K
PiANCj4gSSBzZWUgbm8gbG9ja2luZyBmb3IgdGhlIHR4LXBhdGguDQogDQpJIGFtIG5vdCBzdXJl
IHdoeSBsb2NraW5nIGlzIG5lZWRlZCBpbiB0eC1wYXRoPyANCkhvd2V2ZXIsIGxvb2tpbmcgYXQg
aXQgYWdhaW4sIEkgc2hvdWxkIG1vdmUgdGhlIGluY3JlbWVudGluZyBvZiBoZWFkIGFmdGVyIHRo
ZSAic3RzIiBoYW5kaW5nIHRvIGJlIGFwdC4gV2hhdCBkbyB5b3UgdGhpbms/DQoNClRoYW5rcywN
ClJhbWVzaA0K
