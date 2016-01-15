From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sctp: Move sequence start handling into
 sctp_transport_get_idx()
Date: Fri, 15 Jan 2016 15:12:13 -0500 (EST)
Message-ID: <20160115.151213.2258553264727846515.davem@davemloft.net>
References: <1452865471-32509-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com, lucien.xin@gmail.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452865471-32509-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogR2VlcnQgVXl0dGVyaG9ldmVuIDxnZWVydEBsaW51eC1tNjhrLm9yZz4NCkRhdGU6IEZy
aSwgMTUgSmFuIDIwMTYgMTQ6NDQ6MzEgKzAxMDANCg0KPiBuZXQvc2N0cC9wcm9jLmM6IEluIGZ1
bmN0aW9uIKFzY3RwX3RyYW5zcG9ydF9nZXRfaWR4ojoNCj4gbmV0L3NjdHAvcHJvYy5jOjMxMzog
d2FybmluZzogoW9iaqIgbWF5IGJlIHVzZWQgdW5pbml0aWFsaXplZCBpbiB0aGlzIGZ1bmN0aW9u
DQo+IA0KPiBUaGlzIGlzIGN1cnJlbnRseSBhIGZhbHNlIHBvc2l0aXZlLCBhcyBhbGwgY2FsbGVy
cyBjaGVjayBmb3IgYSB6ZXJvDQo+IG9mZnNldCBmaXJzdCwgYW5kIGhhbmRsZSB0aGlzIGNhc2Ug
aW4gdGhlIGV4YWN0IHNhbWUgd2F5Lg0KPiANCj4gTW92ZSB0aGUgY2hlY2sgYW5kIGhhbmRsaW5n
IGludG8gc2N0cF90cmFuc3BvcnRfZ2V0X2lkeCgpIHRvIGtpbGwgdGhlDQo+IGNvbXBpbGVyIHdh
cm5pbmcsIGFuZCBhdm9pZCBmdXR1cmUgYnVncy4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IEdlZXJ0
IFV5dHRlcmhvZXZlbiA8Z2VlcnRAbGludXgtbTY4ay5vcmc+DQoNCkFwcGxpZWQsIHRoYW5rcyBH
ZWVydC4NCg==
