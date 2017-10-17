From: "Bernat, Yehezkel" <yehezkel.bernat@intel.com>
Subject: Re: [PATCH 2/2 net-next] thunderbolt: Right shifting to zero bug in
 tbnet_handle_packet()
Date: Tue, 17 Oct 2017 13:17:30 +0000
Message-ID: <1508246223.3477.28.camel@intel.com>
References: <20171017123301.z6heqexdlo6lc52b@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "mika.westerberg@linux.intel.com" <mika.westerberg@linux.intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>,
        "Jamet, Michael" <michael.jamet@intel.com>,
        "Levy, Amir (Jer)" <amir.jer.levy@intel.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20171017123301.z6heqexdlo6lc52b@mwanda>
Content-Language: en-US
Content-ID: <9174B1DF670B1C43BBBEDC8064AFDB9F@namprd11.prod.outlook.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T24gVHVlLCAyMDE3LTEwLTE3IGF0IDE1OjMzICswMzAwLCBEYW4gQ2FycGVudGVyIHdyb3RlOg0K
PiBUaGVyZSBpcyBhIHByb2JsZW0gd2hlbiB3ZSBkbzoNCj4gDQo+IAlzZXF1ZW5jZSA9IHBrZy0+
aGRyLmxlbmd0aF9zbiAmIFRCSVBfSERSX1NOX01BU0s7DQo+IAlzZXF1ZW5jZSA+Pj0gVEJJUF9I
RFJfU05fU0hJRlQ7DQo+IA0KPiBUQklQX0hEUl9TTl9TSElGVCBpcyAyNywgYW5kIHJpZ2h0IHNo
aWZ0aW5nIGEgdTggMjcgYml0cyBpcyBhbHdheXMNCj4gZ29pbmcgdG8gcmVzdWx0IGluIHplcm8u
wqDCoFRoZSBmaXggaXMgdG8gZGVjbGFyZSB0aGVzZSB2YXJpYWJsZXMgYXMNCj4gdTMyLg0KPiAN
Cj4gRml4ZXM6IGU2OWI2YzAyYjRjMyAoIm5ldDogQWRkIHN1cHBvcnQgZm9yIG5ldHdvcmtpbmcg
b3Zlcg0KPiBUaHVuZGVyYm9sdCBjYWJsZSIpDQo+IFNpZ25lZC1vZmYtYnk6IERhbiBDYXJwZW50
ZXIgPGRhbi5jYXJwZW50ZXJAb3JhY2xlLmNvbT4NCj4gDQo+IGRpZmYgLS1naXQgYS9kcml2ZXJz
L25ldC90aHVuZGVyYm9sdC5jIGIvZHJpdmVycy9uZXQvdGh1bmRlcmJvbHQuYw0KPiBpbmRleCAx
YTdiYzBiZjQ1OTguLjQzNTg1NDY4OGE3YSAxMDA2NDQNCj4gLS0tIGEvZHJpdmVycy9uZXQvdGh1
bmRlcmJvbHQuYw0KPiArKysgYi9kcml2ZXJzL25ldC90aHVuZGVyYm9sdC5jDQo+IEBAIC0zOTQs
NyArMzk0LDcgQEAgc3RhdGljIGludCB0Ym5ldF9oYW5kbGVfcGFja2V0KGNvbnN0IHZvaWQgKmJ1
ZiwNCj4gc2l6ZV90IHNpemUsIHZvaWQgKmRhdGEpDQo+IMKgCXN0cnVjdCB0Ym5ldCAqbmV0ID0g
ZGF0YTsNCj4gwqAJdTMyIGNvbW1hbmRfaWQ7DQo+IMKgCWludCByZXQgPSAwOw0KPiAtCXU4IHNl
cXVlbmNlOw0KPiArCXUzMiBzZXF1ZW5jZTsNCj4gwqAJdTY0IHJvdXRlOw0KPiDCoA0KPiDCoAkv
KiBNYWtlIHN1cmUgdGhlIHBhY2tldCBpcyBmb3IgdXMgKi8NCg0KQWNrZWQtYnk6IFllaGV6a2Vs
IEJlcm5hdCA8eWVoZXprZWwuYmVybmF0QGludGVsLmNvbT4NCg0KVGhhbmtzIQ0K
