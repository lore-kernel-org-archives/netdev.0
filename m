From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC] csum experts, csum_replace2() is too expensive
Date: Mon, 24 Mar 2014 10:30:19 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6E77A4@AcuExch.aculab.com>
References: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87a9cknwk4.fsf@tassilo.jf.intel.com>
	 <1395406250.9114.142.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140321.145229.1026128975151125729.davem@davemloft.net>
 <1395629410.9117.46.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "andi@firstfloor.org" <andi@firstfloor.org>,
	"hpa@zytor.com" <hpa@zytor.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"hkchu@google.com" <hkchu@google.com>,
	"mwdalton@google.com" <mwdalton@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395629410.9117.46.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogRXJpYyBEdW1hemV0DQo+IE9uIEZyaSwgMjAxNC0wMy0yMSBhdCAxNDo1MiAtMDQwMCwg
RGF2aWQgTWlsbGVyIHdyb3RlOg0KPiA+IEZyb206IEVyaWMgRHVtYXpldCA8ZXJpYy5kdW1hemV0
QGdtYWlsLmNvbT4NCj4gPiBEYXRlOiBGcmksIDIxIE1hciAyMDE0IDA1OjUwOjUwIC0wNzAwDQo+
ID4NCj4gPiA+IEl0IGxvb2tzIGxpa2UgYSBiYXJyaWVyKCkgd291bGQgYmUgbW9yZSBhcHByb3By
aWF0ZS4NCj4gPg0KPiA+IGJhcnJpZXIoKSA9PSBfX2FzbV9fIF9fdm9sYXRpbGVfXyg6OjoibWVt
b3J5IikNCj4gDQo+IEluZGVlZCwgYnV0IG5vdyB5b3UgbWVudGlvbiBpdCwgaXBfZmFzdF9jc3Vt
KCkgZG8gbm90IHVzZXMgdm9sYXRpbGUNCj4ga2V5d29yZCBvbiB4ODZfNjQsIGFuZCBoYXMgbm8g
Im0iIGNvbnN0cmFpbnQgZWl0aGVyLg0KDQpBZGRpbmcgJ3ZvbGF0aWxlJyBpc24ndCBzdWZmaWNp
ZW50IHRvIGZvcmNlIGdjYyB0byB3cml0ZSBkYXRhDQppbnRvIHRoZSBhcmVhIGJlaW5nIGNoZWNr
c3VtbWVkLg0KaXBfZmFzdF9jc3VtKCkgZWl0aGVyIG5lZWRzIGFuIGV4cGxpY2l0ICJtIiBjb25z
dHJhaW50IGZvciB0aGUgYWN0dWFsDQpidWZmZXIgKGFuZCB0YXJnZXQpIGJ5dGVzLCBvciB0aGUg
c3Ryb25nZXIgIm1lbW9yeSIgY29uc3RyYWludC4NClRoZSAndm9sYXRpbGUnIGlzIHRoZW4gbm90
IG5lZWRlZC4NCg0KCURhdmlkDQoNCg==
