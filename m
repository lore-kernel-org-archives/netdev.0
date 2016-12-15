From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 1/4] siphash: add cryptographically secure hashtable
 function
Date: Thu, 15 Dec 2016 13:56:30 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0240437@AcuExch.aculab.com>
References: <20161214035927.30004-1-Jason@zx2c4.com>
 <CAHmME9q9ffdtWRbzyMO1ktTdtEFdfumTfojTTNLXFhoa+R+MWQ@mail.gmail.com>
 <8ea3fdff-23c4-b81d-2588-44549bd2d8c1@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB02401ED@AcuExch.aculab.com>
 <707472e1-b385-836d-c4c6-791c1dcc0776@stressinduktion.org>
 <063D6719AE5E284EB5DD2968C1650D6DB02402C0@AcuExch.aculab.com>
 <0f3c3694-c00b-aae2-5b08-25bc64bf6372@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Netdev <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        "Linux Crypto Mailing List" <linux-crypto@vger.kernel.org>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>
To: 'Hannes Frederic Sowa' <hannes@stressinduktion.org>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <0f3c3694-c00b-aae2-5b08-25bc64bf6372@stressinduktion.org>
Content-Language: en-US
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogSGFubmVzIEZyZWRlcmljIFNvd2ENCj4gU2VudDogMTUgRGVjZW1iZXIgMjAxNiAxMjo1
MA0KPiBPbiAxNS4xMi4yMDE2IDEzOjI4LCBEYXZpZCBMYWlnaHQgd3JvdGU6DQo+ID4gRnJvbTog
SGFubmVzIEZyZWRlcmljIFNvd2ENCj4gPj4gU2VudDogMTUgRGVjZW1iZXIgMjAxNiAxMjoyMw0K
PiA+IC4uLg0KPiA+PiBIbW0/IEV2ZW4gdGhlIEludGVsIEFCSSBleHBlY3RzIGFsaWdubWVudCBv
ZiB1bnNpZ25lZCBsb25nIGxvbmcgdG8gYmUgOA0KPiA+PiBieXRlcyBvbiAzMiBiaXQuIERvIHlv
dSBxdWVzdGlvbiB0aGF0Pw0KPiA+DQo+ID4gWWVzLg0KPiA+DQo+ID4gVGhlIGxpbnV4IEFCSSBm
b3IgeDg2ICgzMiBiaXQpIG9ubHkgcmVxdWlyZXMgMzJiaXQgYWxpZ25tZW50IGZvciB1NjQgKGV0
YykuDQo+IA0KPiBIbW0sIHU2NCBvbiAzMiBiaXQgaXMgdW5zaWduZWQgbG9uZyBsb25nIGFuZCBu
b3QgdW5zaWduZWQgbG9uZy4gVGh1cyBJDQo+IGFtIGFjdHVhbGx5IG5vdCBzdXJlIGlmIHRoZSBB
Qkkgd291bGQgc2F5IGFueXRoaW5nIGFib3V0IHRoYXQgKHNvcnJ5DQo+IGFsc28gZm9yIG15IHdy
b25nIHN0YXRlbWVudCBhYm92ZSkuDQo+IA0KPiBBbGlnbm1lbnQgcmVxdWlyZW1lbnQgb2YgdW5z
aWduZWQgbG9uZyBsb25nIG9uIGdjYyB3aXRoIC1tMzIgYWN0dWFsbHkNCj4gc2VlbSB0byBiZSA4
Lg0KDQpJdCBkZXBlbmRzIG9uIHRoZSBhcmNoaXRlY3R1cmUuDQpGb3IgeDg2IGl0IGlzIGRlZmlu
aXRlbHkgNC4NCkl0IG1pZ2h0IGJlIDggZm9yIHNwYXJjLCBwcGMgYW5kL29yIGFscGhhLg0KDQoJ
RGF2aWQNCg0K
