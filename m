From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Use sk_mark for routing lookup in more places
Date: Fri, 02 Oct 2009 11:00:49 -0700 (PDT)
Message-ID: <20091002.110049.252043637.davem@davemloft.net>
References: <4AC58C46.8080408@gmail.com>
	<4AC598D7.9080900@gmail.com>
	<55a4f86e0910021025u7523029av1e4ee917d1fb1ee5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: eric.dumazet@gmail.com, atis@mikrotik.com, panther@balabit.hu,
	netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47590
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753087AbZJBSA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 14:00:29 -0400
In-Reply-To: <55a4f86e0910021025u7523029av1e4ee917d1fb1ee5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogTWFjaWVqIMW7ZW5jenlrb3dza2kgPHplbmN6eWtvd3NraUBnbWFpbC5jb20+DQpEYXRl
OiBGcmksIDIgT2N0IDIwMDkgMTA6MjU6MTMgLTA3MDANCg0KPiBNYXliZSBpdCB3b3VsZCBtYWtl
IG1vcmUgc2Vuc2UgdG8gY3JlYXRlIHNvbWUgY29uc3RydWN0b3ItbGlrZQ0KPiBmdW5jdGlvbnMg
Zm9yIHRoZSBmbG93aSBzdHJ1Y3Q/DQoNCk1heWJlIGp1c3QgYW4gaW5pdGlhbGl6ZXIgbGlrZSAi
RkxPV0lfU09DSyhzaykiIG9yIHNpbWlsYXIuDQpTbyB5b3UgY2FuIHNheToNCg0KCXN0cnVjdCBm
bG93aSBmbCA9IEZMT1dJX1NPQ0soc2spOw0KDQpCdXQgdGhlIHRoaW5nIGlzIHdlIHVzdWFsbHkg
d2FudCB0byBpbml0aWFsaXplIGFsbCBvZiB0aGUNCmRldGFpbHMgaW4gb25lIGdvLCBzbyB3ZSdk
IG5lZWQgYSB2ZXJ5IG1lc3N5IG1hY3JvIGZvciB0aGlzDQp0aGF0IHdvdWxkIHRha2UgbWFueSBh
cmd1bWVudHMuDQoNCkl0J3MgaW1wb3J0YW50IHRvIHVzZSBhbiBpbml0aWFsaXplciByYXRoZXIg
dGhhbiBhc3NpZ25tZW50cyBpbiBzb21lDQppbmxpbmUgZnVuY3Rpb24gc28gdGhhdCBHQ0MgY2Fu
IGJldHRlciBjb2FsZXNjZSBtYW55IHNtYWxsIG1lbWJlcnMNCmludG8gc2luY2UgbGFyZ2Ugc3Rv
cmVzIHRvIHRoZSBzdGFjay4gIEl0IGRvZXNuJ3QgZG8gdGhpcyBhcyB3ZWxsIHdpdGgNCnJlYWwg
YXNzaWdubWVudCBzdGF0ZW1lbnRzLg0K
