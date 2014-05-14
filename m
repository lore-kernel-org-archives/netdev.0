From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v4 2/2] net: systemport: pad packets to a
 minimum of 64 bytes
Date: Wed, 14 May 2014 08:51:07 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D172442ED@AcuExch.aculab.com>
References: <1399666599-19398-1-git-send-email-f.fainelli@gmail.com>
 <1399666599-19398-3-git-send-email-f.fainelli@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F7116C2@AcuExch.aculab.com>
 <CAGVrzcadcBzoLL9sxnuZ-rszpO-h4BircuWxNr4a7oFHbKxtXA@mail.gmail.com>
 <CAGVrzcYKVm8Pps_DHrXmZ6wd6d6A3k7FjkEn9sVDo1PwA1fZcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: 'Florian Fainelli' <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:38190 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752048AbaENIvQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 04:51:16 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 25150-01 for <netdev@vger.kernel.org>;
 Wed, 14 May 2014 09:51:06 +0100 (BST)
In-Reply-To: <CAGVrzcYKVm8Pps_DHrXmZ6wd6d6A3k7FjkEn9sVDo1PwA1fZcw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRmxvcmlhbiBGYWluZWxsaSANCi4uLg0KPiA+Pj4gKyAgICAgaWYgKHNrYl9wYWR0byhz
a2IsIDY0KSkgew0KPiA+Pg0KPiA+PiBTaG91bGRuJ3QgdGhhdCBiZSA2MD8NCj4gPg0KPiA+IEl0
IHNob3VsZCwgYWJzb2x1dGVseSwgYW5kIHRoYXQgaXMgRVRIX1pMRU4uIFRoYW5rcyENCj4gDQo+
IEluIGZhY3QsIG5vLCBkZXNwaXRlIHRoZSBFdGhlcm5ldCBNQUMgYXBwZW5kaW5nIHRoZSBDUkMs
IHRoZSBtaW5pbXVtDQo+IHBhY2tldCBsZW5ndGggZnJvbSB0aGUgRE1BIHBlcnNwZWN0aXZlIHJl
YWxseSBuZWVkcyB0byBiZSA2NCwgYXMgdGhlDQo+IGhhcmR3YXJlIGluc2VydGVkIENSQyBpcyBu
b3QgYWNjb3VudGVkIGZvciB0byBnZW5lcmF0ZSB0aGUgRW5kIG9mDQo+IFBhY2tldCBzaWduYWwu
IFRoYXQganVzdCB0cmFuc2xhdGVzIGludG8gRVRIX1pMRU4gKyBFVEhfRkNTX0xFTg0KPiBhbnl3
YXkuDQoNCkhtbW0uLi4uIFRoYXQgcmVhbGx5IGRvZXNuJ3Qgc291bmQgcmlnaHQuDQpUaGUgQ1JD
IGNhbid0IGJlIHJlcGxhY2luZyB0aGUgbGFzdCA0IGJ5dGVzIG9mIHRoZSBza2IgLSBvdGhlcndp
c2UNCmxvbmdlciBwYWNrZXRzIHdvdWxkIGJlIGNvcnJ1cHRlZC4NClNvIEknbSBzdXJlIHRoYXQg
eW91IGFyZSBwYWRkaW5nIGZyYW1lcyB0byA2OCBieXRlcy4NCldoaWxlIGEgdHlwaWNhbCBJUCBp
bXBsZW1lbnRhdGlvbiBwcm9iYWJseSBpZ25vcmVzIHBhZCBieXRlcyBhZnRlcg0KYW55IGxlbmd0
aCBmcmFtZSwgb3RoZXIgcHJvdG9jb2xzIHdpbGwgb25seSBleHBlY3QgcGFkZGluZyBvbiBzaG9y
dA0KZnJhbWVzIC0gYW5kIHRoZW4gb25seSB0byB0aGUgbWluaW11bSBmcmFtZSBsZW5ndGguDQoN
CglEYXZpZA0KDQo=
