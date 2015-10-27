From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [Intel-wired-lan] [PATCHv2] ixgbe: Wait for 1ms, not 1us, after
 RST
Date: Tue, 27 Oct 2015 23:02:25 +0000
Message-ID: <1445986945.21669.11.camel@intel.com>
References: <20151027183559.GA14014@aiaiai.jf.intel.com>
	 <562FFE71.6090901@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "dan.streetman@canonical.com" <dan.streetman@canonical.com>,
	"peter@hurleysoftware.com" <peter@hurleysoftware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <562FFE71.6090901@hurleysoftware.com>
Content-Language: en-US
Content-ID: <0C1E5DF787D1CC4BB75B5E8483AEA296@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T24gVHVlLCAyMDE1LTEwLTI3IGF0IDE4OjQ1IC0wNDAwLCBQZXRlciBIdXJsZXkgd3JvdGU6DQo+
IE9uIDEwLzI3LzIwMTUgMDI6MzUgUE0sIE5EIExpbnV4IENJIFNlcnZlciB3cm90ZToNCj4gPiBH
cmVldGluZ3MsDQo+ID4gDQo+ID4gVGhpcyBlbWFpbCBpcyBhdXRvbWF0aWNhbGx5IGdlbmVyYXRl
ZCBieSBORCdzIExpbnV4IFBhdGNoIFRlc3RpbmcNCj4gPiBmcmFtZXdvcmsNCj4gPiBiYXNlZCBv
biBhaWFpYWkuIEkgaGF2ZSBwZXJmb3JtZWQgc29tZSBhdXRvbWF0aWMgdGVzdGluZyBvZiBhIHBh
dGNoDQo+ID4gKHNlcmllcykNCj4gPiB5b3Ugc3VibWl0dGVkIHRvIGludGVsLXdpcmVkLWxhbkBs
aXN0cy5vc3Vvc2wub3JnDQo+ID4gDQo+ID4gVGhlIGZvbGxvd2luZyBjb250YWlucyBvdXRwdXQg
b2YgYW55IHRlc3RzIHdoaWNoIGZhaWxlZCB0byBwYXNzLA0KPiA+IGFuZCBtaWdodCBiZQ0KPiA+
IHRoZSByZXN1bHQgb2YgZGV2ZWxvcGVyIGVycm9yLiBUaGUgdGVzdHMgcGVyZm9ybWVkIGluY2x1
ZGUgYnV0IG1heQ0KPiA+IG5vdCBiZQ0KPiA+IGxpbWl0ZWQgdG8gY2hlY2twYXRjaC5wbCwgYmlz
ZWN0aW9uIHRlc3RpbmcsIGNvbXBpbGF0aW9uIG9uIGENCj4gPiBkZWZhdWx0IGtlcm5lbA0KPiA+
IGNvbmZpZywgY29jY2luZWxsZSBzY3JpcHRzLCBjcHBjaGVjaywgYW5kIHNtYXRjaC4NCj4gPiAN
Cj4gPiBJZiB5b3UgaGF2ZSByZWNlaXZlZCB0aGlzIGVtYWlsIGluIGVycm9yLCBvciBiZWxpZXZl
IHRoYXQgYWlhaWFpDQo+ID4gaGFzIGRldGVjdGVkIGENCj4gPiBmYWxzZSBwb3NpdGl2ZSwgcGxl
YXNlIGVtYWlsIEphY29iIEtlbGxlciA8amFjb2IuZS5rZWxsZXJAaW50ZWwuY29tDQo+ID4gPi4N
Cj4gDQo+IEZhbHNlIHBvc2l0aXZlLg0KPiANCj4gQXMgbG9uZyBhcyB0aGUgZGVsYXkgaXMgYXQg
bGVhc3QgMW1zICh3aGljaCBpcyBndWFyYW50ZWVkKSwgc2xpZ2h0bHkNCj4gbG9uZ2VyDQo+IGRl
bGF5cyAocmVsYXRpdmUgdG8gdGhlIGV4aXN0aW5nIHJlc2V0IGRlbGF5IG9mIDEwMG1zKSBhcmUg
bm90DQo+IGhhcm1mdWwuDQo+IA0KPiBVc2Ugb2YgdXNsZWVwX3JhbmdlKCkgd291bGQgYmUgdW5u
ZWNlc3Nhcnkgb3ZlcmtpbGwgZm9yIHRoZSBwdXJwb3NlLg0KPiANCj4gUmVnYXJkcywNCj4gUGV0
ZXIgSHVybGV5DQoNCg0KRmVlbCBmcmVlIHRvIGlnbm9yZSB0aGlzIHRoZW4uDQoNClJlZ2FyZHMs
DQpKYWtl
