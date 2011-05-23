From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ping: cleanups ping_v4_unhash()
Date: Mon, 23 May 2011 16:29:54 -0400 (EDT)
Message-ID: <20110523.162954.818069883349610972.davem@davemloft.net>
References: <1306138981.2869.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, segoon@openwall.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47605 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933534Ab1EWUac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 16:30:32 -0400
In-Reply-To: <1306138981.2869.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29tPg0KRGF0ZTogTW9uLCAy
MyBNYXkgMjAxMSAxMDoyMzowMCArMDIwMA0KDQo+IG5ldC9pcHY0L3BpbmcuYzogSW4gZnVuY3Rp
b24goXBpbmdfdjRfdW5oYXNoojoNCj4gbmV0L2lwdjQvcGluZy5jOjE0MDoyODogd2FybmluZzog
dmFyaWFibGUgoWhzbG90oiBzZXQgYnV0IG5vdCB1c2VkDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBF
cmljIER1bWF6ZXQgPGVyaWMuZHVtYXpldEBnbWFpbC5jb20+DQo+IENDOiBWYXNpbGl5IEt1bGlr
b3YgPHNlZ29vbkBvcGVud2FsbC5jb20+DQoNCkFwcGxpZWQuDQo=
