From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] Force speed and duplex mode setting if link down
Date: Tue, 3 Jun 2014 09:13:17 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17256451@AcuExch.aculab.com>
References: <1401750420-6668-1-git-send-email-stannous@cumulusnetworks.com>
 <CAGVrzcZMkjFHjE3O80nPe4hmRUgfjWsoY0_g6dNPHKvBRKpOmg@mail.gmail.com>
 <1075088676.3395812.1401760022657.JavaMail.zimbra@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev <netdev@vger.kernel.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>
To: 'Sam Tannous' <stannous@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:59970 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750930AbaFCJNl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2014 05:13:41 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 04897-01 for <netdev@vger.kernel.org>;
 Tue,  3 Jun 2014 10:13:33 +0100 (BST)
In-Reply-To: <1075088676.3395812.1401760022657.JavaMail.zimbra@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogT2YgU2FtIFRhbm5vdXMNCj4gDQo+IEkgcHJvYmFibHkgZGlkbid0IG1ha2UgdGhpcyBj
bGVhciBlbm91Z2ggaW4gdGhlIGRlc2NyaXB0aW9uLg0KPiBJJ20gbm90IGRlc2NyaWJpbmcgYSB1
c2UgY2FzZS4gICBJJ20gc2ltcGx5IGNoYW5naW5nIHRoZQ0KPiBzcGVlZCBvbiB0d28gaW50ZXJm
YWNlcyB0aGF0IGFyZSBkaXJlY3RseSBjb25uZWN0ZWQuDQo+IEkgZG9uJ3QgaGF2ZSBhdXRvbmVn
IG9uIGF0IGFsbC4NCj4gDQo+IDEuIEkgc3RhcnQgd2l0aCBhIHdvcmtpbmcgbGluayB3aGVyZSB0
aGUgc3BlZWQgaXMNCj4gICAgMTBHIGFuZCBkdXBsZXggaXMgZnVsbCBvbiBib3RoIHNpZGVzLg0K
PiANCj4gMi4gSSBjaGFuZ2UgdGhlIHNwZWVkIG9uIG9uZSBzaWRlIHRvIDFHIHdpdGgNCj4gDQo+
ICAgICAgIGV0aHRvb2wgLXMgc3BlZWQgMTAwMA0KPiANCj4gICAgYW5kIHRoZSBjb21tYW5kIGFw
cGVhcnMgdG8gd29yayAoYXQgbGVhc3QgdGhlcmUgaXMgbm8gZXJyb3IgbWVzc2FnZSkuDQo+ICAg
IE9uY2UgSSBpc3N1ZSB0aGlzIGNvbW1hbmQsIHRoZSBsaW5rIGlzIG5vIGxvbmdlciB1c2FibGUN
Cj4gICAgc2luY2UgdGhlIHNwZWVkIGNoYW5nZWQgb24gb25lIHNpZGUgYnV0IG5vdCB0aGUgb3Ro
ZXIuICBBdXRvbmVnDQo+ICAgIGlzIGRpc2FibGVkIChieSBkZWZhdWx0KS4NCg0KWW91IHJlYWxs
eSB3YW50IHRvIGxlYXZlIGF1dG9uZWcgZW5hYmxlZCBhbmQganVzdCBsaW1pdCB0aGUgYWR2ZXJ0
aXNlZA0Kc3BlZWRzLg0KDQpJIHN1c3BlY3QgdGhlcmUgYXJlIHBsZW50eSBvZiB3YXlzIGV0aHRv
b2wgY2FuIGJlIHVzZWQgdG8gbWFrZQ0Kbm9uLXdvcmtpbmcgaW50ZXJmYWNlcywgc29tZSBvZiB0
aGVtIG1pZ2h0IGJlIG5lZWRlZCBiZSBkZXZlbG9wZXJzDQpvciBpbiB1bnVzdWFsIGNpcmN1bXN0
YW5jZXMuDQpTbyBJIGRvbid0IHRoaW5rIGV0aHRvb2wgc2hvdWxkIGJlIHBvbGljaW5nIHRoaXMg
c3BlY2lmaWMgY29uZGl0aW9uLg0KDQpNYXliZSB0aGUgZHJpdmVyIHNob3VsZCBqdXN0IHVzZSBG
RFggd2hlbiBIRFggaXMgaW52YWxpZCBmb3IgdGhlDQpzcGVlZC4NCg0KCURhdmlkDQoNCg==
