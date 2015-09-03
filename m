From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] x86: Wire up 32-bit direct socket calls
Date: Thu, 3 Sep 2015 10:06:24 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB8CE25@AcuExch.aculab.com>
References: <cb5138299d37d5800e2d135b01a7667fa6115854.1436912629.git.luto@kernel.org>
 <CAMuHMdXKA_+JY2ryf-yoJxQnbW=jsOjj_w2-Nsybpx0310neDA@mail.gmail.com>
 <55E75913.5050605@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: X86 ML <x86@kernel.org>, Network Development <netdev@vger.kernel.org>,
	Tulio Magno Quites Machado Filho <tuliom@linux.vnet.ibm.com>, Andy Lutomirski
	<luto@amacapital.net>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Alexander Larsson <alexl@redhat.com>, Cosimo
 Cecchi <cosimo@endlessm.com>, Dan Nicholson <nicholson@endlessm.com>,
	libc-alpha <libc-alpha@sourceware.org>, "Rajalakshmi Srinivasaraghavan"
	<raji@linux.vnet.ibm.com>, Linux-Arch <linux-arch@vger.kernel.org>
To: "'H. Peter Anvin'" <hpa@zytor.com>, Geert Uytterhoeven
	<geert@linux-m68k.org>, Andy Lutomirski <luto@kernel.org>
Return-path: <libc-alpha-return-62918-glibc-alpha=m.gmane.org@sourceware.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
In-Reply-To: <55E75913.5050605@zytor.com>
List-Id: netdev.vger.kernel.org

RnJvbTogUGV0ZXIgQW52aW4NCj4gU2VudDogMDIgU2VwdGVtYmVyIDIwMTUgMjE6MTYNCj4gT24g
MDkvMDIvMjAxNSAwMjo0OCBBTSwgR2VlcnQgVXl0dGVyaG9ldmVuIHdyb3RlOg0KPiA+DQo+ID4g
U2hvdWxkIGFsbCBvdGhlciBhcmNoaXRlY3R1cmVzIGZvbGxvdyBzdWl0Pw0KPiA+IE9yIHNob3Vs
ZCB3ZSBmb2xsb3cgdGhlIHMzOTAgYXBwcm9hY2g6DQo+ID4NCj4gDQo+IEl0IGlzIHVwIHRvIHRo
ZSBtYWludGFpbmVyKHMpLCBsYXJnZWx5IGRlcGVuZGVudCBvbiBob3cgbGlrZWx5IHlvdSBhcmUN
Cj4gZ29pbmcgdG8gd2FudCB0byBzdXBwb3J0IHRoaXMgaW4geW91ciBsaWJjLCBidXQgaW4gZ2Vu
ZXJhbCwgc29ja2V0Y2FsbA0KPiBpcyBhbiBhYm9taW5hdGlvbiB3aGljaCB0aGVyZSBpcyBubyBy
ZWFzb24gbm90IHRvIGJ5cGFzcy4NCg0KVGhlIG90aGVyICh3b3JzZSkgYWJvbWluYXRpb24gaXMg
dGhlIHdheSBTQ1RQIG92ZXJsb2FkcyBzZXRzb2Nrb3B0KCkNCnRvIHBlcmZvcm0gYWN0aW9ucyB0
aGF0IGNoYW5nZSBzdGF0ZS4NClJhdGhlciB1bmZvcnR1bmF0ZWx5IHRoYXQgZ290IGRvY3VtZW50
ZWQgaW4gdGhlIHByb3RvY29sIHN0YW5kYXJkIDotKA0KDQoJRGF2aWQNCg0K
