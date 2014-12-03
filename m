From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH, regression against -rc6] net/stmmac: fix one more
 regression from filter bins setting
Date: Tue, 02 Dec 2014 20:32:52 -0800 (PST)
Message-ID: <20141202.203252.1622139877301467504.davem@davemloft.net>
References: <5388366.Y15J6TLmlA@wuerfel>
	<tencent_0FE25D6968E3D939662D9E00@qq.com>
	<5807934.FFPy2gmHBj@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: chenhc@lemote.com, netdev@vger.kernel.org, khilman@kernel.org,
	peppe.cavallaro@st.com, olof@lixom.net,
	linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56307 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbaLCE2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 23:28:33 -0500
In-Reply-To: <5807934.FFPy2gmHBj@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQXJuZCBCZXJnbWFubiA8YXJuZEBhcm5kYi5kZT4NCkRhdGU6IFNhdCwgMjkgTm92IDIw
MTQgMTc6MjY6NDIgKzAxMDANCg0KPiBPbiBTYXR1cmRheSAyOSBOb3ZlbWJlciAyMDE0IDIzOjQ0
OjIzIOmZiOWNjuaJjSB3cm90ZToNCj4+IEhpLCBBcm5kLA0KPj4gDQo+PiBNYXliZSB0aGlzIHBh
dGNoIGlzIGJldHRlcj8NCj4+IGh0dHA6Ly93d3cuc3Bpbmljcy5uZXQvbGlzdHMvbmV0ZGV2L21z
ZzMwNjQxMy5odG1sDQo+IA0KPiBZZXMsIHRoYXQgd291bGQgd29yayB0b28uIEkgYWxzbyBjaGVj
a2VkIHRoYXQgbXkgdmVyc2lvbiB3b3JrcyBub3cuDQo+IA0KPiBJJ20gZmluZSB3aXRoIGVpdGhl
ciBvbmUsIGFzIGxvbmcgYXMgYSBmaXggbWFrZXMgaXQgaW50byAzLjE4Lg0KDQpJdCdzIGluIHRo
ZSAnbmV0JyB0cmVlLCBJJ2xsIHRyeSB0byBnZXQgaXQgdG8gTGludXMgc29vbi4NCg==
