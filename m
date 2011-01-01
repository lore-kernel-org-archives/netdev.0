From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] tg3: fix warnings
Date: Sat, 01 Jan 2011 13:51:58 -0800 (PST)
Message-ID: <20110101.135158.193714452.davem@davemloft.net>
References: <201012252356.23424.rjw@sisk.pl>
	<20101231.111440.28810446.davem@davemloft.net>
	<1293895366.2535.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: rjw@sisk.pl, netdev@vger.kernel.org, mcarlson@broadcom.com,
	mchan@broadcom.com, linux-pm@lists.linux-foundation.org,
	jesse@nicira.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35428
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752585Ab1AAVv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 16:51:27 -0500
In-Reply-To: <1293895366.2535.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPg0KRGF0ZTogU2F0LCAw
MSBKYW4gMjAxMSAxNjoyMjo0NiArMDEwMA0KDQo+IEhhcHB5IG5ldyB5ZWFyIGV2ZXJ5Ym9keSA7
KQ0KDQpTYW1lIHRvIHlvdSBFcmljIDopDQoNCj4gW1BBVENIIG5ldC1uZXh0LTIuNl0gdGczOiBm
aXggd2FybmluZ3MNCj4gDQo+IEluIGNhc2UgQ09ORklHX1BNX1NMRUVQIGlzIGRpc2FibGVkLCB3
ZSBkb250IG5lZWQgdGczX3N1c3BlbmQoKSBhbmQNCj4gdGczX3Jlc3VtZSgpLg0KPiANCj4gZHJp
dmVycy9uZXQvdGczLmM6MTUwNTY6IHdhcm5pbmc6IKF0ZzNfc3VzcGVuZKIgZGVmaW5lZCBidXQg
bm90IHVzZWQNCj4gZHJpdmVycy9uZXQvdGczLmM6MTUxMTA6IHdhcm5pbmc6IKF0ZzNfcmVzdW1l
oiBkZWZpbmVkIGJ1dCBub3QgdXNlZA0KPiANCj4gU2lnbmVkLW9mZi1ieTogRXJpYyBEdW1hemV0
IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPg0KDQpBcHBsaWVkLCB0aGFua3MuDQo=
