From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lan78xx: Fix ladv/radv error handling in
 lan78xx_link_reset()
Date: Sun, 06 Sep 2015 19:47:18 -0700 (PDT)
Message-ID: <20150906.194718.1930392629598351441.davem@davemloft.net>
References: <1441363648-20738-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: Woojung.Huh@microchip.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441363648-20738-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogR2VlcnQgVXl0dGVyaG9ldmVuIDxnZWVydEBsaW51eC1tNjhrLm9yZz4NCkRhdGU6IEZy
aSwgIDQgU2VwIDIwMTUgMTI6NDc6MjggKzAyMDANCg0KPiBuZXQvdXNiL2xhbjc4eHguYzogSW4g
ZnVuY3Rpb24goWxhbjc4eHhfbGlua19yZXNldKI6DQo+IG5ldC91c2IvbGFuNzh4eC5jOjExMDc6
IHdhcm5pbmc6IGNvbXBhcmlzb24gaXMgYWx3YXlzIGZhbHNlIGR1ZSB0byBsaW1pdGVkIHJhbmdl
IG9mIGRhdGEgdHlwZQ0KPiBuZXQvdXNiL2xhbjc4eHguYzoxMTExOiB3YXJuaW5nOiBjb21wYXJp
c29uIGlzIGFsd2F5cyBmYWxzZSBkdWUgdG8gbGltaXRlZCByYW5nZSBvZiBkYXRhIHR5cGUNCj4g
DQo+IEFzc2lnbmluZyByZXR1cm4gdmFsdWVzIHRoYXQgY2FuIGJlIG5lZ2F0aXZlIGVycm9yIGNv
ZGVzIHRvICJ1MTYiDQo+IHZhcmlhYmxlcyBtYWtlcyB0aGVtIHBvc2l0aXZlLCBpZ25vcmluZyB0
aGUgZXJyb3JzLiAgSGVuY2UgdXNlICJpbnQiDQo+IGluc3RlYWQuDQo+IA0KPiBEcm9wIHRoZSAi
dW5saWtlbHkicyAodW5saWtlbHkgY29uc2lkZXJlZCBoYXJtZnVsKSBhbmQgcHJvcGFnYXRlIHRo
ZQ0KPiBhY3R1YWwgZXJyb3IgdmFsdWVzIGluc3RlYWQgb2Ygb3ZlcnJpZGluZyB0aGVtIHRvIC1F
SU8gd2hpbGUgd2UncmUgYXQNCj4gaXQuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBHZWVydCBVeXR0
ZXJob2V2ZW4gPGdlZXJ0QGxpbnV4LW02OGsub3JnPg0KDQpBcHBsaWVkLCB0aGFua3MuDQo=
