From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH net 1/2] r8152: add pre_reset and post_reset
Date: Tue, 28 Jul 2015 09:52:15 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2F3C3EC@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-156-Taiwan-albertk@realtek.com>
	 <1394712342-15778-157-Taiwan-albertk@realtek.com>
 <1438073562.11934.2.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	nic_swsd <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1438073562.11934.2.camel-IBi9RG/b67k@public.gmane.org>
Content-Language: zh-TW
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

T2xpdmVyIE5ldWt1bSBbbWFpbHRvOm9uZXVrdW1Ac3VzZS5jb21dDQo+IFNlbnQ6IFR1ZXNkYXks
IEp1bHkgMjgsIDIwMTUgNDo1MyBQTQ0KWy4uLl0NCj4gPiArCQlyZXR1cm4gMDsNCj4gPiArDQo+
ID4gKwluZXRkZXYgPSB0cC0+bmV0ZGV2Ow0KPiA+ICsJaWYgKCFuZXRpZl9ydW5uaW5nKG5ldGRl
dikpDQo+ID4gKwkJcmV0dXJuIDA7DQo+ID4gKw0KPiA+ICsJcmV0ID0gdXNiX2F1dG9wbV9nZXRf
aW50ZXJmYWNlKGludGYpOw0KPiA+ICsJaWYgKHJldCA8IDApDQo+ID4gKwkJcmV0dXJuIHJldDsN
Cj4gDQo+IFdoYXQgc2Vuc2UgZG9lcyB0aGlzIG1ha2U/DQo+IA0KWy4uLl0NCj4gPiArCQlyZXR1
cm4gMDsNCj4gPiArDQo+ID4gKwluZXRkZXYgPSB0cC0+bmV0ZGV2Ow0KPiA+ICsJaWYgKCFuZXRp
Zl9ydW5uaW5nKG5ldGRldikpDQo+ID4gKwkJcmV0dXJuIDA7DQo+ID4gKw0KPiA+ICsJcmV0ID0g
dXNiX2F1dG9wbV9nZXRfaW50ZXJmYWNlKGludGYpOw0KPiANCj4gVGhlIGRldmljZSB3aWxsIGJl
IGF3YWtlLg0KDQpJIGRvbid0IHN1cmUgaWYgdGhlIGRldmljZSB3b3VsZCBiZSBpbiBydW50aW1l
c3VzcGVuZCwgc28gSSB3YWtlIGl0IHVwIGJ5IG15c2VsZi4NCkkgdGhpbmsgeW91IG1lYW4gSSBk
b24ndCBoYXZlIHRvIGRvIHRoaXMuIEkgd291bGQgcmVtb3ZlIHRoZW0gYW5kIHJlc2VuZCB0aGUN
CnBhdGNoLiBUaGFua3MuDQoNCkJlc3QgUmVnYXJkcywNCkhheWVzDQoNCg==
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
