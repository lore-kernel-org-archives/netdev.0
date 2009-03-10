From: David Miller <davem@davemloft.net>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Tue, 10 Mar 2009 04:30:19 -0700 (PDT)
Message-ID: <20090310.043019.132650585.davem@davemloft.net>
References: <20090309195906.M50328@bts.sk>
	<1e41a3230903091323j541d1895j2eb69b9f9c11f2f3@mail.gmail.com>
	<20090310104956.GA81181@bts.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: johnwheffner@gmail.com, netdev@vger.kernel.org
To: md@bts.sk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57441
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750698AbZCJLad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 07:30:33 -0400
In-Reply-To: <20090310104956.GA81181@bts.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogTWFyaWFuIMSOdXJrb3ZpxI0gPG1kQGJ0cy5zaz4NCkRhdGU6IFR1ZSwgMTAgTWFyIDIw
MDkgMTE6NDk6NTYgKzAxMDANCg0KPiBTZW5kZXIgZG9lcyBub3QgaGF2ZSB0aGUgcmVsZXZhbnQg
aW5mbyB0byBpbXBsZW1lbnQgdGhpcyAtIGl0IG1pZ2h0IGJlDQo+IGNvbm5lY3RlZCBieSAxMCBH
RSB0byB0aGUgaGlnaHNwZWVkIGJhY2tib25lLg0KDQpZZXMsIHRoZSBzZW5kZXIgZG9lcyBpbmRl
ZWQgaGF2ZSB0aGlzIGluZm9ybWF0aW9uLCBhbmQgdXNpbmcgaXQgaXMNCmV4YWN0bHkgd2hhdCBj
b25nZXN0aW9uIGNvbnRyb2wgYWxnb3JpdGhtcyBzdWNoIGFzIFZFR0FTIHRyeSB0byBkby4NCg0K
VGhleSBsb29rIGF0IGJvdGggcm91bmQgdHJpcCB0aW1lcyBhbmQgYmFuZHdpdGggYXMgdGhleSBp
bmNyZWFzZSB0aGUNCnNlbmQgY29uZ2VzdGlvbiB3aW5kb3cuICBBbmQgaWYgcm91bmQgdHJpcHMg
aW5jcmVhc2Ugd2l0aG91dCBhDQpjb3JyZXNwb25kaW5nIGluY3JlYXNlIGluIGJhbmR3aWR0aCwg
dGhleSBzdG9wIGluY3JlYXNpbmcuICBUaGlzIGlzDQpiZWNhdXNlIGluIHN1Y2ggYSBzaXR1YXRp
b24gd2UgY2FuIGluZmVyIHRoYXQgd2UncmUganVzdCBjb25zdW1pbmcNCm1vcmUgcXVldWUgc3Bh
Y2UgYXQgc29tZSBpbnRlcm1lZGlhdGUgcm91dGVyL3N3aXRjaCByYXRoZXIgdGhhbiB1c2luZw0K
bW9yZSBvZiB0aGUgYXZhaWxhYmxlIGJhbmR3aWR0aC4NCg0K
