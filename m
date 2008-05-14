From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] irnet_irda.c must #include <asm/unaligned.h>
Date: Wed, 14 May 2008 15:30:03 -0700 (PDT)
Message-ID: <20080514.153003.77372633.davem@davemloft.net>
References: <20080514202709.GB21795@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: graf.yang@analog.com, cooloney@kernel.org,
	torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44562
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753067AbYENWaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 18:30:09 -0400
In-Reply-To: <20080514202709.GB21795@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQWRyaWFuIEJ1bmsgPGJ1bmtAa2VybmVsLm9yZz4NCkRhdGU6IFdlZCwgMTQgTWF5IDIw
MDggMjM6Mjc6MDkgKzAzMDANCg0KPiBUaGlzIHBhdGNoIGZpeGVzIHRoZSBmb2xsb3dpbmcgY29t
cGlsZSBlcnJvciBjYXVzZWQgYnkNCj4gY29tbWl0IDMzMjIyMzgzMWU4NmIyZTE3YjQ4YjRhZmFm
YWQwN2Q4ZTNiNzM4NjENCj4gKGlyZGE6IEZpeCBhIG1pc2FsaWduIGFjY2VzcyBpc3N1ZS4gKHYy
KSk6DQo+IA0KPiA8LS0gIHNuaXAgIC0tPg0KPiANCj4gLi4uDQo+ICAgQ0MgICAgICBuZXQvaXJk
YS9pcm5ldC9pcm5ldF9pcmRhLm8NCj4gL2hvbWUvYnVuay9saW51eC9rZXJuZWwtMi42L2dpdC9s
aW51eC0yLjYvbmV0L2lyZGEvaXJuZXQvaXJuZXRfaXJkYS5jOiBJbiBmdW5jdGlvbiDigJhpcm5l
dF9kaXNjb3ZlcnlfaW5kaWNhdGlvbuKAmToNCj4gL2hvbWUvYnVuay9saW51eC9rZXJuZWwtMi42
L2dpdC9saW51eC0yLjYvbmV0L2lyZGEvaXJuZXQvaXJuZXRfaXJkYS5jOjE2NzY6IGVycm9yOiBp
bXBsaWNpdCBkZWNsYXJhdGlvbiBvZiBmdW5jdGlvbiDigJhnZXRfdW5hbGlnbmVk4oCZDQo+IG1h
a2VbNF06ICoqKiBbbmV0L2lyZGEvaXJuZXQvaXJuZXRfaXJkYS5vXSBFcnJvciAxDQo+IA0KPiA8
LS0gIHNuaXAgIC0tPg0KPiANCj4gUmVwb3J0ZWQtYnk6IEFkcmlhbiBCdW5rIDxidW5rQGtlcm5l
bC5vcmc+DQo+IFNpZ25lZC1vZmYtYnk6IEFkcmlhbiBCdW5rIDxidW5rQGtlcm5lbC5vcmc+DQoN
CkFwcGxpZWQsIHRoYW5rcyBhIGxvdCBBZHJpYW4uDQo=
