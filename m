From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rds: Fix min() warning in
 rds_message_inc_copy_to_user()
Date: Mon, 15 Dec 2014 11:49:23 -0500 (EST)
Message-ID: <20141215.114923.1022314440021305631.davem@davemloft.net>
References: <1418646102-32415-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: viro@zeniv.linux.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43661 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbaLOQtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 11:49:25 -0500
In-Reply-To: <1418646102-32415-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogR2VlcnQgVXl0dGVyaG9ldmVuIDxnZWVydEBsaW51eC1tNjhrLm9yZz4NCkRhdGU6IE1v
biwgMTUgRGVjIDIwMTQgMTM6MjE6NDIgKzAxMDANCg0KPiBuZXQvcmRzL21lc3NhZ2UuYzogSW4g
ZnVuY3Rpb24goXJkc19tZXNzYWdlX2luY19jb3B5X3RvX3VzZXKiOg0KPiBuZXQvcmRzL21lc3Nh
Z2UuYzozMjg6IHdhcm5pbmc6IGNvbXBhcmlzb24gb2YgZGlzdGluY3QgcG9pbnRlciB0eXBlcyBs
YWNrcyBhIGNhc3QNCj4gDQo+IFVzZSBtaW5fdCh1bnNpZ25lZCBsb25nLCAuLi4pIGxpa2UgaXMg
ZG9uZSBpbg0KPiByZHNfbWVzc2FnZV9jb3B5X2Zyb21fdXNlcigpLg0KPiANCj4gU2lnbmVkLW9m
Zi1ieTogR2VlcnQgVXl0dGVyaG9ldmVuIDxnZWVydEBsaW51eC1tNjhrLm9yZz4NCg0KQWxzbyBh
cHBsaWVkLCB0aGFua3MgR2VlcnQuDQo=
