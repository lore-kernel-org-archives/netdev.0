From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH] qed: fix memory leak of a qed_spq_entry on error failure
 paths
Date: Sun, 18 Dec 2016 06:33:50 +0000
Message-ID: <BL2PR07MB2306151726E6A6E95702776B8D9E0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <20161216125039.20969-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Elior, Ariel" <Ariel.Elior@cavium.com>,
        "Tayar, Tomer" <Tomer.Tayar@cavium.com>
To: Colin King <colin.king@canonical.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161216125039.20969-1-colin.king@canonical.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiBGcm9tOiBDb2xpbiBJYW4gS2luZyA8Y29saW4ua2luZ0BjYW5vbmljYWwuY29tPg0KPiANCj4g
QSBxZWRfc3BxX2VudHJ5IGVudHJ5IGlzIGFsbG9jYXRlZCBieSBxZWRfc3BfaW5pdF9yZXF1ZXN0
IGJ1dCBpcyBub3Qga2ZyZWUnZA0KPiBpZiBhbiBlcnJvciBvY2N1cnMsIGNhdXNpbmcgYSBtZW1v
cnkgbGVhay4gRml4IHRoaXMgYnkga2ZyZWUnaW5nIGl0IGFuZCBhbHNvDQo+IHNldHRpbmcgKnBw
X2VudCB0byBOVUxMIHRvIGJlIHNhZmUuDQo+IA0KPiBGb3VuZCB3aXRoIHN0YXRpYyBhbmFseXNp
cyBieSBDb3Zlcml0eVNjYW4sIENJRHMgMTM4OTQ2OC0xMzg5NDcwDQo+IA0KPiBTaWduZWQtb2Zm
LWJ5OiBDb2xpbiBJYW4gS2luZyA8Y29saW4ua2luZ0BjYW5vbmljYWwuY29tPg0KLi4uDQo+ICtl
cnI6DQo+ICsJa2ZyZWUoKnBwX2VudCk7DQo+ICsJKnBwX2VudCA9IE5VTEw7DQo+ICsNCj4gKwly
ZXR1cm4gcmM7DQo+ICB9DQoNCkhpIENvbGluIC0gdGhhbmtzIGZvciB0aGlzLg0KSXQgd291bGQg
aGF2ZSBiZWVuIHByZWZlcmFibGUgdG8gcmV0dXJuIHRoZSBwcmV2aW91c2x5IGFsbG9jYXRlZCBz
cHEgZW50cnkuDQpJLmUuLCBkbzoNCg0KK2VycjoNCisJcWVkX3NwcV9yZXR1cm5fZW50cnkocF9o
d2ZuLCAqcHBfZW50KTsNCisJKnBwX2VudCA9IE5VTEw7DQorCXJldHVybiByYzsNCg0KVGhhbmtz
LA0KWXV2YWwNCg==
