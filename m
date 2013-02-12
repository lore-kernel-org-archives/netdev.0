From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/2] net: calexdaxgmac: fixup endian issues after __raw IO function change
Date: Tue, 12 Feb 2013 09:19:52 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7145@saturn3.aculab.com>
References: <1360510721-17860-1-git-send-email-ben.dooks@codethink.co.uk>  <1360510721-17860-3-git-send-email-ben.dooks@codethink.co.uk> <1360606656.2701.18.camel@bwh-desktop.uk.solarflarecom.com> <5119382F.8000809@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	"Rob Herring" <rob.herring@calxeda.com>,
	<linux-arm-kernel@lists.infradead.org>
To: "Ben Dooks" <ben.dooks@codethink.co.uk>,
	"Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:38711 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932303Ab3BLJVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2013 04:21:03 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 00893-02 for <netdev@vger.kernel.org>;
 Tue, 12 Feb 2013 09:20:56 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <5119382F.8000809@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IFlvdSBhcmUgdXNpbmcgbGUzMl90b19jcHUoKSBhbmQgY3B1X3RvX2xlMzIoKSB0aGUgd3Jv
bmcgd2F5IHJvdW5kLCBhbmQNCj4gPiB0aGVuIHB1dHRpbmcgY2FzdHMgb24gdGhlIHdyb25nIHNp
ZGUsIGkuZS4gaXQgc2hvdWxkIGJlOg0KPiA+DQo+ID4gCXZhbHVlID0gbGUzMl90b19jcHUoKF9f
Zm9yY2UgX19sZTMyKV9fcmF3X3JlYWRsKGFkZHIpKTsNCj4gPiAJX19yYXdfd3JpdGVsKChfX2Zv
cmNlIHUzMiljcHVfdG9fbGUzMih2YWx1ZSksIGFkZHIpOw0KPiA+DQo+ID4gKEkgZG8gd29uZGVy
IHdoeSBfX3JhdyBJL08gZnVuY3Rpb25zIGFyZW4ndCBkZWNsYXJlZCB0byB0YWtlL3JldHVybiBf
X2xlDQo+ID4gdHlwZXMuLi4gaXQgd291bGQgYXZvaWQgdGhlIG5lZWQgdG8gY2FzdCBhbHRvZ2V0
aGVyLikNCj4gDQo+IEJlY2F1c2UgdGhleSBkbyB0aGluZ3Mgd2l0aCB0aGUgb3JkZXIgdGhlIGNw
dSBpcyB3b3JraW5nIGluLCB0aGUNCj4gcmVhZHt4fSBhbmQgd3JpdGV7eH0gdHJhbnNmZXIgY3B1
IHRvIGJ1cy1lbmRpYW4gc28gcmV0dXJuaW5nIGFuIF9fbGUNCj4gdHlwZSB3b3VsZCBub3QgYmUg
Y29ycmVjdC4NCg0KU3VyZWx5IHlvdSB3YW50IHRvIGFycmFuZ2UgdG8gdXNlIHRoZSBieXRlLXN3
YXBwaW5nIG1lbW9yeQ0KcmVhZC93cml0ZSBpbnN0cnVjdGlvbnMsIHJhdGhlciB0aGFuIGJ5dGVz
d2FwcGluZyB0aGUgdmFsdWUuDQoNClBhcnRpY3VsYXJseSBvbiBwcGMgd2hpY2ggZG9lc24ndCBo
YXZlIGEgYnl0ZXN3YXAgaW5zdHJ1Y3Rpb24NCmJ1dCBjYW4gZG8gYnl0ZXN3YXBwaW5nIG1lbW9y
eSBhY2Nlc3Nlcy4NCg0KCURhdmlkDQoNCg==
