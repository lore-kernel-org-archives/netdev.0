From: Shaohui Xie <shaohui.xie-3arQi8VN3Tc@public.gmane.org>
Subject: RE: [PATCH 1/3][v2] net: phy: introduce 1000BASE-KX and 10GBASE-KR
Date: Mon, 18 Jan 2016 07:23:27 +0000
Message-ID: <VI1PR04MB16645A2F24DB515D86136BE2E8C00@VI1PR04MB1664.eurprd04.prod.outlook.com>
References: <1452759839-9874-1-git-send-email-shh.xie@gmail.com>
 <20160114164418.GD19773@lunn.ch>
 <VI1PR04MB166491DEBB439EB72742201DE8CD0@VI1PR04MB1664.eurprd04.prod.outlook.com>
 <56997951.90304@gmail.com> <5699B211.5070602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Shaohui Xie <Shaohui.Xie-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
	"shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5699B211.5070602-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

PiA+IElmIHlvdSBsb29rIGF0IHRoZSBsaXN0IG9mIHBvc3NpYmxlIHZhbHVlcyBmb3IgInBoeS1t
b2RlIiB5b3UnZCBzZWUNCj4gPiB0aGF0IG5vbmUgb2YgaXQgZGVzY3JpYmVzIGEgUEhZLXRvLVBI
WSBjb25uZWN0aW9uIGJ1dCBhbGwgYXJlIGZvcg0KPiA+IE1BQy10by1QSFkgY29ubmVjdGlvbnMu
IEFsc28sIG5hbWVzIGFib3ZlIHN1Z2dlc3QgaXQgYWxyZWFkeTogTUlJIGlzDQo+ID4gc2hvcnQg
Zm9yIG1lZGlhIF9pbmRlcGVuZGVudF8gaW50ZXJmYWNlLg0KPiA+DQo+ID4gSSBjb3B5IEFuZHJl
dydzIGNvbmNlcm5zIGFuZCB0aGluayB0aGF0IG5laXRoZXIgMTAwMDBiYXNlLWt4IG5vcg0KPiA+
IDEwZ2Jhc2Uta3IgYmVsb25nIGluIHRoZSBsaXN0IG9mIHBoeS1tb2RlIHByb3BlcnRpZXMuDQo+
IA0KPiBJIGNvbmN1ciB3aXRoIHRoYXQgYXMgd2VsbCwgaWYgdGhlIHBoeSBjb25uZWN0aW9uIGRv
ZXMgbm90IHJlYWxseSBtYXR0ZXIgaGVyZSwNCj4gb3IgZG9lcyBub3Qgc2VlbSBsaWtlIGEgZ29v
ZCBmaXQsIG1heWJlIHdlIHNob3VsZCBoYXZlIGEgZGlmZmVyZW50IHByb3BlcnR5LCBvcg0KPiBq
dXN0IGRlZmluZSB0aGUgaGFyZHdhcmUgaW50ZXJmYWNlIGEgbGl0dGxlIGRpZmZlcmVudGx5Pw0K
UmlnaHQsICdwaHktbW9kZScgaXMgbm90IGEgZ29vZCBmaXQgZm9yIGJhY2twbGFuZXMsIGhvdyBh
Ym91dCBhIG5ldyBwcm9wZXJ0eSBsaWtlDQonYmFja3BsYW5lLW1vZGUnIG9yIHNvbWV0aGluZywg
bGlrZSBiZWxvdzoNCg0KLS0tIGEvRG9jdW1lbnRhdGlvbi9kZXZpY2V0cmVlL2JpbmRpbmdzL25l
dC9waHkudHh0DQorKysgYi9Eb2N1bWVudGF0aW9uL2RldmljZXRyZWUvYmluZGluZ3MvbmV0L3Bo
eS50eHQNCkBAIC0zMyw2ICszMyw5IEBAIE9wdGlvbmFsIFByb3BlcnRpZXM6DQogLSBicm9rZW4t
dHVybi1hcm91bmQ6IElmIHNldCwgaW5kaWNhdGVzIHRoZSBQSFkgZGV2aWNlIGRvZXMgbm90IGNv
cnJlY3RseQ0KICAgcmVsZWFzZSB0aGUgdHVybiBhcm91bmQgbGluZSBsb3cgYXQgdGhlIGVuZCBv
ZiBhIE1ESU8gdHJhbnNhY3Rpb24uDQogDQorLSBiYWNrcGxhbmUtbW9kZTogc3RyaW5nLCBvcGVy
YXRpb24gbW9kZSBvZiB0aGUgYmFja3BsYW5lIFBIWTsNCisgIG11c3QgYmUgIjEwMDBiYXNlLWt4
IiBmb3IgMTAwMEJBU0UtS1gsIG9yICIxMGdiYXNlLWtyIiBmb3IgMTBHQkFTRS1LUi4NCisNCiBF
eGFtcGxlOg0KIA0KIGV0aGVybmV0LXBoeUAwIHsNCg0KVGhhbmsgeW91IQ0KDQpTaGFvaHVpDQo=
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
