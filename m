From: Robert MARKLUND <robert.marklund@stericsson.com>
Subject: RE: [PATCH 2/2 v4] net/smsc911x: Add regulator support
Date: Wed, 16 Nov 2011 13:59:41 +0100
Message-ID: <2B1D156D95AE9B4EAD379CB9E465FE7324AECE3650@EXDCVYMBSTM005.EQ1STM.local>
References: <1320064719-14449-1-git-send-email-robert.marklund@stericsson.com>
 <201110311421.18653.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Mathieu Poirier <mathieu.poirier@linaro.org>,
	Paul Mundt <lethal@linux-sh.org>,
	"linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Tony Lindgren <tony@atomide.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"uclinux-dist-devel@blackfin.uclinux.org"
	<uclinux-dist-devel@blackfin.uclinux.org>,
	Linus Walleij <linus.walleij@linaro.org>
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201110311421.18653.vapier@gentoo.org>
Content-Language: en-US
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DQo+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+IEZyb206IE1pa2UgRnJ5c2luZ2VyIFtt
YWlsdG86dmFwaWVyQGdlbnRvby5vcmddDQo+IFNlbnQ6IGRlbiAzMSBva3RvYmVyIDIwMTEgMTk6
MjENCj4gVG86IFJvYmVydCBNQVJLTFVORA0KPiBDYzogbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsg
U3RldmUgR2xlbmRpbm5pbmc7IE1hdGhpZXUgUG9pcmllcjsgUGF1bCBNdW5kdDsgbGludXgtc2hA
dmdlci5rZXJuZWwub3JnOw0KPiBTYXNjaGEgSGF1ZXI7IFRvbnkgTGluZGdyZW47IGxpbnV4LW9t
YXBAdmdlci5rZXJuZWwub3JnOyB1Y2xpbnV4LWRpc3QtZGV2ZWxAYmxhY2tmaW4udWNsaW51eC5v
cmc7DQo+IExpbnVzIFdhbGxlaWoNCj4gU3ViamVjdDogUmU6IFtQQVRDSCAyLzIgdjRdIG5ldC9z
bXNjOTExeDogQWRkIHJlZ3VsYXRvciBzdXBwb3J0DQo+IA0KPiBPbiBNb25kYXkgMzEgT2N0b2Jl
ciAyMDExIDA4OjM4OjM5IFJvYmVydCBNYXJrbHVuZCB3cm90ZToNCj4gPiBDaGFuZ2VMb2cgdjMt
PnY0Og0KPiA+IC0gUmVtb3ZlIGR1YWwgcHJpbnRzIGFuZCBvbGQgY29tbWVudCBvbiBNaWtlJ3Mg
cmVxdWVzdC4NCj4gPiAtIFNwbGl0IHRoZSByZXF1ZXN0X2ZyZWUgZnVjbnRpb24gb24gTWlrZSBh
bmQgU2FzY2hhIHJlcXVlc3QuDQo+IA0KPiB3b3VsZCBiZSBuaWNlIGlmIHRoZSBlbmFibGUvZGlz
YWJsZSB3ZXJlIHNwbGl0IGFzIHdlbGwgLi4uDQoNCkkgaW50ZXJwcmV0IHRoaXMgYXMgIm5pY2Ug
aWYiLCBpZiBpdCdzIGEgIm11c3QgYmUiIHRoZW4gaWxsIGNoYW5nZSBpdC4NCg0KPiANCj4gPiAg
CWlvdW5tYXAocGRhdGEtPmlvYWRkcik7DQo+ID4NCj4gPiArCSh2b2lkKXNtc2M5MTF4X2VuYWJs
ZV9kaXNhYmxlX3Jlc291cmNlcyhwZGV2LCBmYWxzZSk7DQo+IA0KPiBpIGRvbid0IHRoaW5rIHRo
ZSAodm9pZCkgY2FzdCBpcyBuZWNlc3NhcnkNCg0KSSBsaWtlIHRlbGxpbmcgdGhlIHJlYWRlciBv
ZiB0aGUgY29kZSB0aGF0IEkgaWdub3JlIHRoZSByZXR1cm4gdmFsdWUsIA0KSSBkaWQgbm90IGp1
c3QgZm9yZ2V0IGl0Lg0KDQovUg0KDQo+IA0KPiBvdGhlcndpc2UgbG9va3MgZmluZQ0KPiAtbWlr
ZQ0K
