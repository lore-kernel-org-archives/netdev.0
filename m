From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 net 2/2] tg3: Fix data corruption on 5725 with TSO
Date: Tue, 14 May 2013 09:40:26 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7236@saturn3.aculab.com>
References: <1368479056-11780-1-git-send-email-nsujir@broadcom.com> <1368479056-11780-3-git-send-email-nsujir@broadcom.com> <1368479644.13473.121.camel@edumazet-glaptop> <51915C7D.2000407@broadcom.com> <1368481224.13473.124.camel@edumazet-glaptop> <51915F77.5000405@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>, <stable@vger.kernel.org>
To: "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <51915F77.5000405@broadcom.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiA+Pj4+ICsJaWYgKHRnM19hc2ljX3Jldih0cCkgPT0gQVNJQ19SRVZfNTc2MiAmJiBtc3MpIHsN
Cj4gPj4+PiArCQl1MzIgYmFzZSA9ICh1MzIpIG1hcHBpbmcgJiAweGZmZmZmZmZmOw0KPiA+Pj4+
ICsNCj4gPj4+PiArCQlyZXR1cm4gKChiYXNlICsgbGVuICsgKG1zcyAmIDB4M2ZmZikpIDwgYmFz
ZSk7DQouLi4NCj4gRm9yIHRoZSBidWcgdG8gb2NjdXIsIHRoZSBmcmFnbWVudCBkb2VzIG5vdCBo
YXZlIHRvIHNwYW4gYSA0RyBib3VuZGFyeS4gSWYgaXQgaXMNCj4gd2l0aGluIE1TUyBieXRlcyAo
OS42aykgb2YgYSA0RyBib3VuZGFyeSwgaXQgdHJpZ2dlcnMgdGhlIGZhaWx1cmUuDQoNCldvdWxk
IGl0IGJlIHdvcnRoIHNpbXBsaWZ5aW5nIHRoZSB0ZXN0IHRvIGFzc3VtZSB0aGF0ICdsZW4nDQpp
cyA2NGsgYW5kICdtc3MnIDkuNms/DQooY29tbWVudGluZyBvbiB0aGUgYWN0dWFsIGNvbmRpdGlv
bi4pDQpUaGUgbnVtYmVyIG9mIGZhbHNlIHBvc2l0aXZlcyB3b3VsZCBiZSBzbWFsbCwgYnV0IHRo
ZSB0ZXN0DQphIGxvdCBxdWlja2VyLg0KVGhlICcodTMyKW1hcHBpbmcgKyAoMHgxMDAwMCArIDk2
MDApIDwgKHUzMiltYXBwaW5nJyB0ZXN0IG1pZ2h0DQpldmVuIGJlIGZhc3RlciB0aGFuIHRoZSAn
IHRnM19hc2ljX3Jldih0cCkgPT0gQVNJQ19SRVZfNTc2Micgb25lLg0KDQoJRGF2aWQNCg0K
