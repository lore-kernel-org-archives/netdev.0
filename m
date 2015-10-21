From: David Miller <davem@davemloft.net>
Subject: Re: [patch] irda: precedence bug in irlmp_seq_hb_idx()
Date: Wed, 21 Oct 2015 07:48:43 -0700 (PDT)
Message-ID: <20151021.074843.86098207040820210.davem@davemloft.net>
References: <----An------QYmAn$4202951b-482d-4d92-98c2-3466de737b40@alibaba-inc.com>
	<20151019101649.GC26688@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: samuel@sortiz.org, netdev@vger.kernel.org, security@kernel.org,
	throber3@gmail.com, chengmiao.cj@alibaba-inc.com
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44560 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752242AbbJUOcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 10:32:20 -0400
In-Reply-To: <20151019101649.GC26688@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGFuIENhcnBlbnRlciA8ZGFuLmNhcnBlbnRlckBvcmFjbGUuY29tPg0KRGF0ZTogTW9u
LCAxOSBPY3QgMjAxNSAxMzoxNjo0OSArMDMwMA0KDQo+IFRoaXMgaXMgZGVjcmVtZW50aW5nIHRo
ZSBwb2ludGVyLCBpbnN0ZWFkIG9mIHRoZSB2YWx1ZSBzdG9yZWQgaW4gdGhlDQo+IHBvaW50ZXIu
ICBLQVNhbiBkZXRlY3RzIGl0IGFzIGFuIG91dCBvZiBib3VuZHMgcmVmZXJlbmNlLg0KPiANCj4g
UmVwb3J0ZWQtYnk6ICJCZXJyecKgQ2hlbmcg56iL5ZCbKOaIkOa3vCkiIDxjaGVuZ21pYW8uY2pA
YWxpYmFiYS1pbmMuY29tPg0KPiBTaWduZWQtb2ZmLWJ5OiBEYW4gQ2FycGVudGVyIDxkYW4uY2Fy
cGVudGVyQG9yYWNsZS5jb20+DQoNCkFwcGxpZWQgYW5kIHF1ZXVlZCB1cCBmb3IgLXN0YWJsZSwg
dGhhbmtzLg0K
