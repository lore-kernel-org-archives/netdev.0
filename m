From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 1/3] siphash: add cryptographically secure hashtable
 function
Date: Thu, 15 Dec 2016 10:22:41 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB02401BC@AcuExch.aculab.com>
References: <20161214035927.30004-1-Jason@zx2c4.com>
 <20161214184605.24006-1-Jason@zx2c4.com>
 <CALx6S35UgTyqkYUjS5gYFH4HnjW974WQ_JiDXxgb9rZ7gnY52Q@mail.gmail.com>
 <CAHmME9oMaQOhzJbNKh8GN759iJngeRdXt3naOnFhY9mD6t5Kxg@mail.gmail.com>
 <CAHmME9pR3tD2zknKsYaFaTJm_3aBBOA6c174hypm6S-q9wp5nw@mail.gmail.com>
 <CALx6S35VBjw42G6rHPrNfVaBfLMz3YZVjs3D3hBG=4gp5+g5tA@mail.gmail.com>
 <CAHmME9rpvf4tyDjZcJAJxMAW1LcqNm7DiquiYX0uQhRzDLbwqw@mail.gmail.com>
 <CA+55aFyBGQpEKiAcs0w58ZEie+L8OrWvf_2hvGx4E=L56p5hMg@mail.gmail.com>
 <CAHmME9pu6No0wqPzPpaBwQR_b+5CXvh0kke7J8ouN=rx4pxMGg@mail.gmail.com>
 <CA+55aFw4QLuwkxq4VzLMPTJTec-hOu1Fi8e076TNnW0Yq9yp8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Tom Herbert <tom@herbertland.com>, Netdev <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Eric Biggers <ebiggers3@gmail.com>
To: 'Linus Torvalds' <torvalds@linux-foundation.org>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CA+55aFw4QLuwkxq4VzLMPTJTec-hOu1Fi8e076TNnW0Yq9yp8A@mail.gmail.com>
Content-Language: en-US
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogTGludXMgVG9ydmFsZHMNCj4gU2VudDogMTUgRGVjZW1iZXIgMjAxNiAwMDoxMQ0KPiBP
biBXZWQsIERlYyAxNCwgMjAxNiBhdCAzOjM0IFBNLCBKYXNvbiBBLiBEb25lbmZlbGQgPEphc29u
QHp4MmM0LmNvbT4gd3JvdGU6DQo+ID4NCj4gPiBPciBkb2VzIHlvdXIgcmVhc29uYWJsZSBkaXNs
aWtlIG9mICJ3b3JkIiBzdGlsbCBhbGxvdyBmb3IgdGhlIHVzZSBvZg0KPiA+IGR3b3JkIGFuZCBx
d29yZCwgc28gdGhhdCB0aGUgY3VycmVudCBmdW5jdGlvbiBuYW1lcyBvZjoNCj4gDQo+IGR3b3Jk
IHJlYWxseSBpcyBjb25mdXNpbmcgdG8gcGVvcGxlLg0KPg0KPiBJZiB5b3UgaGF2ZSBhIE1JUFMg
YmFja2dyb3VuZCwgaXQgbWVhbnMgNjQgYml0cy4gV2hpbGUgdG8gcGVvcGxlIHdpdGgNCj4gV2lu
ZG93cyBwcm9ncmFtbWluZyBiYWNrZ3JvdW5kcyBpdCBtZWFucyAzMiBiaXRzLg0KDQpHdWVzcyB3
aGF0IGEgRFdPUkRfUFRSIGlzIG9uIDY0Yml0IHdpbmRvd3MgLi4uDQooaXQgaXMgYW4gaW50ZWdl
ciB0eXBlKS4NCg0KCURhdmlkDQoNCg==
