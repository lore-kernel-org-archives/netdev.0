From: Yoshihiro Shimoda <yoshihiro.shimoda.uh-zM6kxYcvzFBBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH] dt-bindings: net: renesas-ravb: Add support for R8A77995
 RAVB
Date: Thu, 14 Sep 2017 00:11:12 +0000
Message-ID: <TY1PR06MB09928CA5EC51D95B135AE662D86F0@TY1PR06MB0992.apcprd06.prod.outlook.com>
References: <1505305060-4192-1-git-send-email-yoshihiro.shimoda.uh@renesas.com>
 <1f4763ea-9f8a-03a6-1215-69b96c404590@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org"
        <linux-renesas-soc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "mark.rutland-5wv7dgnIgG8@public.gmane.org" <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1f4763ea-9f8a-03a6-1215-69b96c404590-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Content-Language: ja-JP
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

SGVsbG8hDQoNCj4gRnJvbTogU2VyZ2VpIFNodHlseW92DQo+IFNlbnQ6IFRodXJzZGF5LCBTZXB0
ZW1iZXIgMTQsIDIwMTcgMTowMiBBTQ0KPiANCj4gSGVsbG8hDQo+IA0KPiBPbiAwOS8xMy8yMDE3
IDAzOjE3IFBNLCBZb3NoaWhpcm8gU2hpbW9kYSB3cm90ZToNCj4gDQo+ID4gQWRkIGEgbmV3IGNv
bXBhdGlibGUgc3RyaW5nIGZvciB0aGUgUjhBNzc5OTUgKFItQ2FyIEQzKSBSQVZCLg0KPiA+DQo+
ID4gU2lnbmVkLW9mZi1ieTogWW9zaGloaXJvIFNoaW1vZGEgPHlvc2hpaGlyby5zaGltb2RhLnVo
QHJlbmVzYXMuY29tPg0KPiA+IC0tLQ0KPiA+ICAgRG9jdW1lbnRhdGlvbi9kZXZpY2V0cmVlL2Jp
bmRpbmdzL25ldC9yZW5lc2FzLHJhdmIudHh0IHwgMSArDQo+ID4gICAxIGZpbGUgY2hhbmdlZCwg
MSBpbnNlcnRpb24oKykNCj4gPg0KPiA+IGRpZmYgLS1naXQgYS9Eb2N1bWVudGF0aW9uL2Rldmlj
ZXRyZWUvYmluZGluZ3MvbmV0L3JlbmVzYXMscmF2Yi50eHQNCj4gYi9Eb2N1bWVudGF0aW9uL2Rl
dmljZXRyZWUvYmluZGluZ3MvbmV0L3JlbmVzYXMscmF2Yi50eHQNCj4gPiBpbmRleCAxNjcyMzUz
Li5hZTIyMTNmIDEwMDY0NA0KPiA+IC0tLSBhL0RvY3VtZW50YXRpb24vZGV2aWNldHJlZS9iaW5k
aW5ncy9uZXQvcmVuZXNhcyxyYXZiLnR4dA0KPiA+ICsrKyBiL0RvY3VtZW50YXRpb24vZGV2aWNl
dHJlZS9iaW5kaW5ncy9uZXQvcmVuZXNhcyxyYXZiLnR4dA0KPiA+IEBAIC0xNyw2ICsxNyw3IEBA
IFJlcXVpcmVkIHByb3BlcnRpZXM6DQo+ID4NCj4gPiAgICAgICAgIC0gInJlbmVzYXMsZXRoZXJh
dmItcjhhNzc5NSIgZm9yIHRoZSBSOEE3Nzk1IFNvQy4NCj4gPiAgICAgICAgIC0gInJlbmVzYXMs
ZXRoZXJhdmItcjhhNzc5NiIgZm9yIHRoZSBSOEE3Nzk2IFNvQy4NCj4gPiArICAgICAgLSAicmVu
ZXNhcyxldGhlcmF2Yi1yOGE3Nzk5NSIgZm9yIHRoZSBSOEE3Nzk5NSBTb0MuDQo+IA0KPiAgICAg
VGhhdCB3b3VsZCBjb25mbGljdCB3aXRoIHRoZSBSOEE3Nzk3MCBiaW5kaW5ncyBwYXRjaCBwb3N0
ZWQgYnkgbWUNCj4geWVzdGVyZGF5LiBQbGVhc2UgcmVzcGluIGF0b3Agb2YgaXQuDQoNClllcywg
SSBzdWJtaXR0ZWQgdjIgcGF0Y2ggbm93Lg0KDQo+ID4gICAgICAgICAtICJyZW5lc2FzLGV0aGVy
YXZiLXJjYXItZ2VuMyIgYXMgYSBmYWxsYmFjayBmb3IgdGhlIGFib3ZlDQo+ID4gICAJCVItQ2Fy
IEdlbjMgZGV2aWNlcy4NCj4gPg0KPiANCj4gICAgIE9uZSBtb3JlIGZyYWdtZW50IGlzIG5lZWRl
ZCBoZXJlLCBhYm91dCB0aGUgbWFuZGF0b3J5ICdpbnRlcnJ1cHQtbmFtZXMiDQo+IHByb3AuIE15
IHBhdGNoIG1ha2VzIHRoaXMgY2hhbmdlIHVubmVjZXNzYXJ5LCBob3dldmVyLi4uDQoNCkkgdW5k
ZXJzdG9vZCBpdC4NCg0KQmVzdCByZWdhcmRzLA0KWW9zaGloaXJvIFNoaW1vZGENCg0KPiBNQlIs
IFNlcmdlaQ0K
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
