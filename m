From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000e: Fix compilation warning when !CONFIG_PM_SLEEP
Date: Thu, 16 Jan 2014 15:36:50 -0800 (PST)
Message-ID: <20140116.153650.1123366219148240100.davem@davemloft.net>
References: <1389875979-30340-1-git-send-email-mika.westerberg@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: davidx.m.ertman@intel.com, aaron.f.brown@intel.com,
	jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com,
	netdev@vger.kernel.org
To: mika.westerberg@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55006 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbaAPXgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 18:36:51 -0500
In-Reply-To: <1389875979-30340-1-git-send-email-mika.westerberg@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogTWlrYSBXZXN0ZXJiZXJnIDxtaWthLndlc3RlcmJlcmdAbGludXguaW50ZWwuY29tPg0K
RGF0ZTogVGh1LCAxNiBKYW4gMjAxNCAxNDozOTozOSArMDIwMA0KDQo+IENvbW1pdCA3NTA5OTYz
YzcwM2IgKGUxMDAwZTogRml4IGEgY29tcGlsZSBmbGFnIG1pcy1tYXRjaCBmb3INCj4gc3VzcGVu
ZC9yZXN1bWUpIG1vdmVkIHN1c3BlbmQgYW5kIHJlc3VtZSBob29rcyB0byBiZSBhdmFpbGFibGUg
d2hlbg0KPiBDT05GSUdfUE0gaXMgc2V0LiBIb3dldmVyLCBpdCBjYW4gYmUgc2V0IGV2ZW4gaWYg
Q09ORklHX1BNX1NMRUVQIGlzIG5vdCBzZXQNCj4gY2F1c2luZyBmb2xsb3dpbmcgd2FybmluZ3Mg
dG8gYmUgZW1pdHRlZDoNCj4gDQo+IGRyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2UxMDAwZS9u
ZXRkZXYuYzo2MTc4OjEyOiB3YXJuaW5nOg0KPiAgIAmhZTEwMDBfc3VzcGVuZKIgZGVmaW5lZCBi
dXQgbm90IHVzZWQgWy1XdW51c2VkLWZ1bmN0aW9uXQ0KPiANCj4gZHJpdmVycy9uZXQvZXRoZXJu
ZXQvaW50ZWwvZTEwMDBlL25ldGRldi5jOjYxODU6MTI6IHdhcm5pbmc6DQo+IAmhZTEwMDBfcmVz
dW1loiBkZWZpbmVkIGJ1dCBub3QgdXNlZCBbLVd1bnVzZWQtZnVuY3Rpb25dDQo+IA0KPiBUbyBm
aXggdGhpcyBtYWtlIHRoZSBob29rcyB0byBiZSBhdmFpbGFibGUgb25seSB3aGVuIENPTkZJR19Q
TV9TTEVFUCBpcyBzZXQNCj4gYW5kIHJlbW92ZSBDT05GSUdfUE0gd3JhcHBpbmcgZnJvbSBkcml2
ZXIgb3BzIGJlY2F1c2UgdGhpcyBpcyBhbHJlYWR5DQo+IGhhbmRsZWQgYnkgU0VUX1NZU1RFTV9T
TEVFUF9QTV9PUFMoKSBhbmQgU0VUX1JVTlRJTUVfUE1fT1BTKCkuDQo+IA0KPiBTaWduZWQtb2Zm
LWJ5OiBNaWthIFdlc3RlcmJlcmcgPG1pa2Eud2VzdGVyYmVyZ0BsaW51eC5pbnRlbC5jb20+DQoN
CkFwcGxpZWQsIHRoYW5rcy4NCg==
