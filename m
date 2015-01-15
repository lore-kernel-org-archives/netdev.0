From: Nakashima Akihiro <Nakashima.Akihiro@exc.epson.co.jp>
Subject: RE: PROBLEM: [3.4] neigh_destroy() crashes on unplug netdev.
Date: Thu, 15 Jan 2015 07:50:41 +0000
Message-ID: <E694983F62A0954788A62E997021A9C3109443@JPEX011.apo.epson.net>
References: <E694983F62A0954788A62E997021A9C31093E1@JPEX011.apo.epson.net>
 <1421305399.11734.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ueda Motoki <Ueda.Motoki@exc.epson.co.jp>,
	"Otsu Takahiro" <Otsu.Takahiro@exc.epson.co.jp>,
	Tomono Mitsunori <Tomono.Mitsunori@exc.epson.co.jp>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421305399.11734.40.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: ja-JP
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RGVhciBFcmljOg0KDQozLjYgb3IgbGF0ZXIga2VybmVscyAoaW5jbHVkaW5nIHJlY2VudCBtYWlu
bGluZSkgZG8gbm90IGhhdmUgdGhpcyBwcm9ibGVtLg0KMy40LjEwNSBpcyBiYXNlZCBvbiBhbiBv
bGQga2VybmVsLCBidXQgaXQgaXMgYSBsYXRlc3Qga2VybmVsIG9mIDMuNCBMVFMgYnJhbmNoLg0K
SSB0aGluayBpdCBpcyBiZXR0ZXIgdG8gYmFja3BvcnQgMjAgcGF0Y2hlcyB0byBMVFMgYnJhbmNo
Lg0KQnV0IGlmIHlvdSBkbyBub3QgaGF2ZSBzdWNoIHN1cHBvcnQgcG9saWN5LCBJIHdpbGwgYXBw
bHkgdGhlc2UgcGF0Y2hlcyB0byBteSAzLjQga2VybmVsIG9ubHkuDQoNClRoYW5rcw0KDQotLS0t
LU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KRnJvbTogRXJpYyBEdW1hemV0IFttYWlsdG86ZXJpYy5k
dW1hemV0QGdtYWlsLmNvbV0gDQpTZW50OiBUaHVyc2RheSwgSmFudWFyeSAxNSwgMjAxNSA0OjAz
IFBNDQpUbzogTmFrYXNoaW1hIEFraWhpcm8NCkNjOiBkYXZlbUBkYXZlbWxvZnQubmV0OyBuZXRk
ZXZAdmdlci5rZXJuZWwub3JnOyBVZWRhIE1vdG9raTsgT3RzdSBUYWthaGlybzsgVG9tb25vIE1p
dHN1bm9yaTsgbGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZw0KU3ViamVjdDogUmU6IFBST0JM
RU06IFszLjRdIG5laWdoX2Rlc3Ryb3koKSBjcmFzaGVzIG9uIHVucGx1ZyBuZXRkZXYuDQoNCk9u
IFRodSwgMjAxNS0wMS0xNSBhdCAwNTo1NyArMDAwMCwgTmFrYXNoaW1hIEFraWhpcm8gd3JvdGU6
DQo+IERlYXIgRGF2aWQgYW5kIG5ldHdvcmtpbmcgZGV2ZWxvcGVyczoNCj4gDQo+IEkgZ290IGtl
cm5lbCBwYW5pYyBvbiAzLjQuMTA1IGtlcm5lbC4NCj4gUGxlYXNlIHNlZSBhIHJlcG9ydCBiZWxv
dy4NCg0KUGxlYXNlIHRyeSBhIHJlY2VudCBrZXJuZWwuDQoNCldlIGFyZSBub3QgZ29pbmcgdG8g
ZGVidWcgc3VjaCBhbiBvbGQgb25lLCBnaXZlbiB0aGVyZSBhcmUgY2hhbmNlcyB3ZSBhbHJlYWR5
IGZpeGVkIHRoZSBwcm9ibGVtIGFnZXMgYWdvLg0KDQpUaGFua3MNCg0KDQoNCg==
