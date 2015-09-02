From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH nf-next] netfilter: nf_dup{4,6}: fix build error when
 nf_conntrack disabled
Date: Wed, 02 Sep 2015 16:28:26 -0700 (PDT)
Message-ID: <20150902.162826.1354616827708594425.davem__31813.2973080084$1441236522$gmane$org@davemloft.net>
References: <dc51f50f4680ff2d2a91b9852fe6f44f0f14d2cf.1441219641.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: pablo@netfilter.org, fw@strlen.de, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40063 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752368AbbIBX21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 19:28:27 -0400
In-Reply-To: <dc51f50f4680ff2d2a91b9852fe6f44f0f14d2cf.1441219641.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGFuaWVsIEJvcmttYW5uIDxkYW5pZWxAaW9nZWFyYm94Lm5ldD4NCkRhdGU6IFdlZCwg
IDIgU2VwIDIwMTUgMjA6NTQ6MDIgKzAyMDANCg0KPiBXaGlsZSB0ZXN0aW5nIHZhcmlvdXMgS2Nv
bmZpZyBvcHRpb25zIG9uIGFub3RoZXIgaXNzdWUsIEkgZm91bmQgdGhhdA0KPiB0aGUgZm9sbG93
aW5nIG9uZSB0cmlnZ2VycyBhcyB3ZWxsIG9uIGFsbG1vZGNvbmZpZyBhbmQgbmZfY29ubnRyYWNr
DQo+IGRpc2FibGVkOg0KPiANCj4gICBuZXQvaXB2NC9uZXRmaWx0ZXIvbmZfZHVwX2lwdjQuYzog
SW4gZnVuY3Rpb24goW5mX2R1cF9pcHY0ojoNCj4gICBuZXQvaXB2NC9uZXRmaWx0ZXIvbmZfZHVw
X2lwdjQuYzo3MjoyMDogZXJyb3I6IKFuZl9za2JfZHVwbGljYXRlZKIgdW5kZWNsYXJlZCAoZmly
c3QgdXNlIGluIHRoaXMgZnVuY3Rpb24pDQo+ICAgICBpZiAodGhpc19jcHVfcmVhZChuZl9za2Jf
ZHVwbGljYXRlZCkpDQo+ICAgWy4uLl0NCj4gICBuZXQvaXB2Ni9uZXRmaWx0ZXIvbmZfZHVwX2lw
djYuYzogSW4gZnVuY3Rpb24goW5mX2R1cF9pcHY2ojoNCj4gICBuZXQvaXB2Ni9uZXRmaWx0ZXIv
bmZfZHVwX2lwdjYuYzo2NjoyMDogZXJyb3I6IKFuZl9za2JfZHVwbGljYXRlZKIgdW5kZWNsYXJl
ZCAoZmlyc3QgdXNlIGluIHRoaXMgZnVuY3Rpb24pDQo+ICAgICBpZiAodGhpc19jcHVfcmVhZChu
Zl9za2JfZHVwbGljYXRlZCkpDQo+IA0KPiBGaXggaXQgYnkgaW5jbHVkaW5nIGRpcmVjdGx5IHRo
ZSBoZWFkZXIgd2hlcmUgaXQgaXMgZGVmaW5lZC4NCj4gDQo+IEZpeGVzOiBiYmRlOWZjMTgyNGEg
KCJuZXRmaWx0ZXI6IGZhY3RvciBvdXQgcGFja2V0IGR1cGxpY2F0aW9uIGZvciBJUHY0L0lQdjYi
KQ0KPiBTaWduZWQtb2ZmLWJ5OiBEYW5pZWwgQm9ya21hbm4gPGRhbmllbEBpb2dlYXJib3gubmV0
Pg0KDQpJJ2xsIHRha2UgdGhpcyBkaXJlY3RseSB0byBzaW1wbGlmeSB0aGluZ3MuDQoNClRoYW5r
cyBEYW5pZWwuDQo=
