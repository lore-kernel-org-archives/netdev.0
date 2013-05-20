From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] x86: bpf_jit_comp: secure bpf jit against spraying attacks
Date: Mon, 20 May 2013 15:35:58 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B723F@saturn3.aculab.com>
References: <1368844623.3301.142.camel@edumazet-glaptop> <20130520141941.GA16412@breakpoint.cc> <1369059993.3301.174.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David Miller" <davem@davemloft.net>,
	"netdev" <netdev@vger.kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>, <linux-kernel@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Florian Westphal" <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43779 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756616Ab3ETOh1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 May 2013 10:37:27 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 29012-08 for <netdev@vger.kernel.org>;
 Mon, 20 May 2013 15:37:20 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1369059993.3301.174.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IFdoYXQgYWJvdXQgZW1pdHRpbmcgYWRkaXRpb25hbCBpbnN0cnVjdGlvbnMgYXQgcmFuZG9t
IGxvY2F0aW9ucyBpbiB0aGUNCj4gPiBnZW5lcmF0ZWQgY29kZSBpdHNlbGY/DQo+ID4NCj4gPiBF
Zy4sIGFmdGVyIGV2ZXJ5IGluc3RydWN0aW9uLCBoYXZlIHJhbmRvbSBjaGFuY2UgdG8gaW5zZXJ0
DQo+ID4gJ3hvciAkMHhjYywlYWw7IHhvciAkMHhjYywlYWwnLCBldGM/DQo+IA0KPiBUaGlzIHdp
bGwgYmUgdGhlIGxhdGVzdCB0aGluZyBJJ2xsIGRvLg0KPiANCj4gRnJhbmtseSwgd2hvbGUgcG9p
bnQgb2YgQlBGIEpJVCBpcyBzcGVlZC4NCj4gDQo+IElmIHdlIGhhdmUgc2xvdyBjb2RlLCBqdXN0
IHVzZSB0aGUgaW50ZXJwcmV0b3IgaW5zdGVhZC4NCg0KQWRkaW5nIG9uZSBvZiB0aGUgc3RhbmRh
cmQgbm9wIG9wY29kZXMgd291bGRuJ3QgYmUgdG9vIGJhZC4NCklJUkMgMHg5MCBpcyBza2lwcGVk
IHZlcnkgZWFybHkgb24gYnkgbW9kZXJuIGNwdS4NCkFkZGluZyBvbmUgYWZ0ZXIgZXZlcnkgbnRo
IChvciBuLW10aCkgaW5zdHJ1Y3Rpb24gd291bGQNCnByb2JhYmx5IGJyZWFrIHRoZSBhbHRlcm5h
dGUgaW5zdHJ1Y3Rpb24gc3RyZWFtLg0KDQpIb3dldmVyIHRoZSBhdHRhY2tlciBjb3VsZCAocHJv
YmFibHkpIGtlZXAgaW5zdGFsbGluZw0KY29kZSBwYXR0ZXJucyB1bnRpbCB0aGUgZ3Vlc3MgcGF0
dGVybiBtYXRjaGVkLg0KDQpBbHNvIHRoZSBjb2RlIHNpemUgY2hhbmdlcyBtaWdodCBtYWtlIHRo
ZSBKSVQgY29tcGlsZSBmYWlsDQotIG1heWJlIGJlY2F1c2Ugb2YgYnJhbmNoIG9mZnNldHMsIG9y
IGp1c3Qgc2l6ZS4NCg0KCURhdmlkDQoNCg==
