From: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [RFC v3 2/2] iwlwifi: mvm: send large SKBs to the transport
Date: Thu, 22 Oct 2015 12:07:59 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32E8AC94B@hasmsx107.ger.corp.intel.com>
References: <1445452464-19525-1-git-send-email-emmanuel.grumbach@intel.com>
	 <1445452464-19525-3-git-send-email-emmanuel.grumbach@intel.com>
 <1445515406.22974.107.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Sharon, Sara" <sara.sharon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org" <ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1445515406.22974.107.camel-XN9IlZ5yJG9HTL0Zs8A6p/gx64E7kk8eUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

PiANCj4gT24gV2VkLCAyMDE1LTEwLTIxIGF0IDIxOjM0ICswMzAwLCBFbW1hbnVlbCBHcnVtYmFj
aCB3cm90ZToNCj4gPiArDQo+ID4gKwkJaWYgKHNrYi0+cHJvdG9jb2wgPT0gaHRvbnMoRVRIX1Bf
SVApKSB7DQo+ID4gKwkJCWlwX2hkcih0bXApLT5pZCA9IGlwX2hkcihza2IpLT5pZDsNCj4gDQo+
IFRvbyBsYXRlLCB5b3UgYWxyZWFkeSBjYWxsZWQgY29uc3VtZV9za2Ioc2tiKS4NCj4gU28gdGhp
cyBpcyBhIHBvdGVudGlhbCB1c2UgYWZ0ZXIgZnJlZS4NCg0KT3VjaCAtIHRoYW5rcyBmb3IgY2F0
Y2hpbmcgdGhpcyENCg0KPiANCj4gPiArCQkJYmUxNl9hZGRfY3B1KCZpcF9oZHIodG1wKS0+aWQs
IGkgKg0KPiBudW1fc3ViZnJhbWVzKTsNCj4gPiArCQl9DQo+ID4gKw0KPiANCj4gDQo+IEkgd291
bGQgdXNlDQo+IGJhc2VfaWQgPSBpcF9oZHIoc2tiKS0+aWQ7IC8vIGJlZm9yZSB0aGUgY29uc3Vt
ZV9za2Ioc2tiKQ0KPiBpcF9oZHIodG1wKS0+aWQgPSBodG9ucyhiYXNlX2lkICsgaSAqIG51bV9z
dWJmcmFtZXMpOw0KPiANClN1cmUgLSBJIHdpbGwuDQoNCkkgd2lsbCBzZW5kIGEgdjQgd2l0aCB0
aGUgZml4ZXMuDQo=
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
