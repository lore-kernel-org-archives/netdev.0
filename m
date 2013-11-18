From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload burst.
Date: Mon, 18 Nov 2013 09:48:52 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7428@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B740B@saturn3.aculab.com> <Pine.LNX.4.44L0.1311131113090.1424-100000@iolanthe.rowland.org> <AE90C24D6B3A694183C094C60CF0A2F6026B741A@saturn3.aculab.com> <1384565904.29151.66.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Alan Stern" <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	"Sarah Sharp" <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Ben Hutchings" <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <1384565904.29151.66.camel-/LGg1Z1CJKQ+9kgCwbf1HqK4ta4zdZpAajtMo4Cw6ucAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

PiA+IEJ1dCB0aGUgbWluaW11bSBmcmFnbWVudCBzaXplIGlzIChwcm9iYWJseSkgNGsuDQo+ID4g
Rm9yIHRoZSBuZXR3b3JrIHN0YWNrIGFuIE9VVCB0cmFuc2ZlciBtaWdodCBoYXZlIGEgbG90IChh
bmQgSSBtZWFuIGxvdHMpDQo+ID4gb2YgZnJhZ21lbnRzICh0aGVyZSBtYXkgYmUgY29uc3RyYWlu
dHMsIGFuZCBsaW5lYXJpc2luZyB0aGUgc2tiIGlzIGEgb3B0aW9uKS4NCj4gWy4uLl0NCj4gDQo+
IFRoZSBtYXhpbXVtIG51bWJlciBvZiBmcmFnbWVudHMgaW4gdGhlIHNrYiBpcyBnb2luZyB0byBi
ZSAxNyAoaW5jbHVkaW5nDQo+IHRoZSAnaGVhZCcgYXJlYSkuICAoSSdtIGlnbm9yaW5nIE5FVElG
X0ZfRlJBR0xJU1Qgd2hpY2ggaXMgbm90IG5vcm1hbGx5DQo+IHN1cHBvcnRlZCBieSBwaHlzaWNh
bCBkZXZpY2UgZHJpdmVycy4pDQo+IA0KPiBJIGRvbid0IGtub3cgaG93IG1hbnkgZnJhZ21lbnRz
IHRoYXQgY2FuIGVuZCB1cCBhcywgYXQgdGhlIFVTQiBsZXZlbC4NCg0KSWYgeW91IGFzc3VtZSB0
aGF0IGV2ZXJ5IGZyYWdtZW50IGNyb3NzZXMgYSA2NGsgYm91bmRhcnkgdGhhdCB3b3VsZCBiZSAz
NC4NCk9UT0ggSSd2ZSBub3Qgc2VlbiBhIGZyYWdtZW50IG9mIGEgNjRrIFRTTyBzZW5kIGNyb3Nz
aW5nIGEgMzJrDQpib3VuZGFyeSwgYW5kIEkgdGhpbmsgdGhlICdoZWFkJyBhcmVhIGlzIGNvbnN0
cmFpbmVkIHRvIGJlIHBhcnQgb2YNCmEgc2luZ2xlICg0ayBvciBsYXJnZXIpIHBhZ2UuDQoNCklz
bid0IHRoZXJlIHNvbWV0aGluZyBvZGQgYWJvdXQgc2tiIG1lcmdlZCBieSByZWNlaXZlIG9mZmxv
YWQ/DQpJJ3ZlIG5vdCBlbnRpcmVseSBzb3J0ZWQgb3V0IHRoZSBmdWxsIHN0cnVjdHVyZSBvZiBz
a2IuDQoNCglEYXZpZA0KDQo=
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
