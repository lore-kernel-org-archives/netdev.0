From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] phy: fix compiler array bounds warning on settings[]
Date: Wed, 5 Mar 2014 09:10:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6D1440@AcuExch.aculab.com>
References: <20140305003544.23016.55079.stgit@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Bjorn Helgaas' <bhelgaas@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140305003544.23016.55079.stgit@bhelgaas-glaptop.roam.corp.google.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogQmpvcm4gSGVsZ2Fhcw0KPiBXaXRoIC1XZXJyb3I9YXJyYXktYm91bmRzLCBnY2MgdjQu
Ny54IHdhcm5zIHRoYXQgaW4gcGh5X2ZpbmRfdmFsaWQoKSwgdGhlDQo+IHNldHRpbmdzW10gImFy
cmF5IHN1YnNjcmlwdCBpcyBhYm92ZSBhcnJheSBib3VuZHMiLCBJIHRoaW5rIGJlY2F1c2UgaWR4
IGlzDQo+IGEgc2lnbmVkIGludGVnZXIgYW5kIGlmIHRoZSBjYWxsZXIgc3VwcGxpZWQgaWR4IDwg
MCwgd2UgcGFzcyB0aGUgZ3VhcmQgYnV0DQo+IHN0aWxsIHJlZmVyZW5jZSBvdXQgb2YgYm91bmRz
Lg0KDQpOb3QgcmVqZWN0aW5nIHRoZSBwYXRjaCBidXQuLi4NCg0KSnVzdCBpbmRleGluZyBhbiBh
cnJheSB3aXRoICdpbnQnIHNob3VsZG4ndCBjYXVzZSB0aGlzIHdhcm5pbmcsDQpzbyBzb21ld2hl
cmUgYSBjYWxsZXIgbXVzdCBhY3R1YWxseSBiZSBwYXNzaW5nIGFuIGlkeCA8IDAuDQoNCldoaWxl
IGNoYW5naW5nIHRoZSB0eXBlIHRvIHVuc2lnbmVkIHdpbGwgbWFrZSB0aGUgY29tcGFyaXNvbg0K
YWdhaW5zdCB0aGUgYXJyYXkgYm91bmQgcmVqZWN0IHRoZSAtMSwgSSBzdXNwZWN0IHRoYXQgdGhl
DQpzcGVjaWZpYyBjYWxsIHBhdGggZGlkbid0IHJlYWxseSBpbnRlbmQgcGFzc2luZyBhIGhhcmQt
Y29kZWQgLTEuDQoNCkl0IG1pZ2h0IGJlIHdvcnRoIHRyeWluZyB0byBsb2NhdGUgdGhlIGNhbGwg
c2l0ZSB0aGF0IHBhc3NlcyAtMS4NCg0KCURhdmlkDQoNCg==
