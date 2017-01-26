From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: RE: NAPI on USB network drivers
Date: Thu, 26 Jan 2017 01:43:23 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB201A13775@RTITMBSV06.realtek.com.tw>
References: <1485336881.16604.2.camel@suse.com>
         <0835B3720019904CB8F7AA43166CEEB201A134A7@RTITMBSV06.realtek.com.tw>
 <1485353591.5145.8.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1485353591.5145.8.camel-XN9IlZ5yJG9HTL0Zs8A6p+yfmBU6pStAUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Content-Language: zh-TW
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

RXJpYyBEdW1hemV0IFttYWlsdG86ZXJpYy5kdW1hemV0QGdtYWlsLmNvbV0NCj4gU2VudDogV2Vk
bmVzZGF5LCBKYW51YXJ5IDI1LCAyMDE3IDEwOjEzIFBNDQpbLi4uXQ0KPiBZb3UgYWxzbyBjb3Vs
ZCB1c2UgbmFwaV9jb21wbGV0ZV9kb25lKCkgaW5zdGVhZCBvZiBuYXBpX2NvbXBsZXRlKCksIGFz
DQo+IGl0IGFsbG93cyB1c2VycyB0byB0dW5lIHRoZSBwZXJmb3JtYW5jZSB2cyBsYXRlbmN5IGZv
ciBHUk8uDQo+IA0KPiBMb29raW5nIGF0IHRoaXMgZHJpdmVyLCBJIGRvIG5vdCBzZWUgYW55IGxp
bWl0YXRpb24gb24gdGhlIG51bWJlciBvZg0KPiBza2JzIHRoYXQgY2FuIGJlIHB1c2hlZCBpbnRv
IHRwLT5yeF9xdWV1ZS4NCj4gDQo+IEkgd29uZGVyIGlmIHRoaXMgcXVldWUgY2FuIGVuZCB1cCBj
b25zdW1pbmcgYWxsIG1lbW9yeSBvZiBhIGhvc3QgdW5kZXINCj4gc3RyZXNzLg0KPiANCj4gZGlm
ZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3VzYi9yODE1Mi5jIGIvZHJpdmVycy9uZXQvdXNiL3I4MTUy
LmMNCj4gaW5kZXgNCj4gZTE0NjZiNGQyYjZjNzI3MTQ4YTg4NDY3MmJiZDk1OTNiZjA0YjNhYy4u
MjIxZGY0YTkzMWI1YzEwNzNmMTkyMmQwZmEwYg0KPiBiZmYxNThjNzNiN2QgMTAwNjQ0DQo+IC0t
LSBhL2RyaXZlcnMvbmV0L3VzYi9yODE1Mi5jDQo+ICsrKyBiL2RyaXZlcnMvbmV0L3VzYi9yODE1
Mi5jDQo+IEBAIC0xODQwLDcgKzE4NDAsMTAgQEAgc3RhdGljIGludCByeF9ib3R0b20oc3RydWN0
IHI4MTUyICp0cCwgaW50IGJ1ZGdldCkNCj4gIAkJCQlzdGF0cy0+cnhfcGFja2V0cysrOw0KPiAg
CQkJCXN0YXRzLT5yeF9ieXRlcyArPSBwa3RfbGVuOw0KPiAgCQkJfSBlbHNlIHsNCj4gLQkJCQlf
X3NrYl9xdWV1ZV90YWlsKCZ0cC0+cnhfcXVldWUsIHNrYik7DQo+ICsJCQkJaWYgKHVubGlrZWx5
KHNrYl9xdWV1ZV9sZW4oJnRwLT5yeF9xdWV1ZSkgPj0gMTAwMCkpDQo+ICsJCQkJCWtmcmVlX3Nr
Yihza2IpOw0KPiArCQkJCWVsc2UNCj4gKwkJCQkJX19za2JfcXVldWVfdGFpbCgmdHAtPnJ4X3F1
ZXVlLCBza2IpOw0KPiAgCQkJfQ0KPiANCj4gIGZpbmRfbmV4dF9yeDoNCg0KVGhhbmtzIGZvciB5
b3VyIHN1Z2dlc3Rpb24uIEkgd291bGQgc3VibWl0IGl0IGxhdGVyLg0KDQpCZXN0IFJlZ2FyZHMs
DQpIYXllcw0KDQoNCg0K
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
