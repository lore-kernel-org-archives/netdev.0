From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] filter: fix va_list build error
Date: Wed, 01 May 2013 16:29:04 -0400 (EDT)
Message-ID: <20130501.162904.2184734237833081637.davem@davemloft.net>
References: <1367439848-10854-1-git-send-email-xi.wang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: xi.wang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42678 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757088Ab3EAU3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 16:29:08 -0400
In-Reply-To: <1367439848-10854-1-git-send-email-xi.wang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogWGkgV2FuZyA8eGkud2FuZ0BnbWFpbC5jb20+DQpEYXRlOiBXZWQsICAxIE1heSAyMDEz
IDE2OjI0OjA4IC0wNDAwDQoNCj4gVGhpcyBwYXRjaCBmaXhlcyB0aGUgZm9sbG93aW5nIGJ1aWxk
IGVycm9yLg0KPiANCj4gSW4gZmlsZSBpbmNsdWRlZCBmcm9tIGluY2x1ZGUvbGludXgvZmlsdGVy
Lmg6NTI6MCwNCj4gICAgICAgICAgICAgICAgICBmcm9tIGFyY2gvYXJtL25ldC9icGZfaml0XzMy
LmM6MTQ6DQo+IGluY2x1ZGUvbGludXgvcHJpbnRrLmg6NTQ6MjogZXJyb3I6IHVua25vd24gdHlw
ZSBuYW1lIKF2YV9saXN0og0KPiBpbmNsdWRlL2xpbnV4L3ByaW50ay5oOjEwNToyMTogZXJyb3I6
IHVua25vd24gdHlwZSBuYW1lIKF2YV9saXN0og0KPiBpbmNsdWRlL2xpbnV4L3ByaW50ay5oOjEw
ODozMDogZXJyb3I6IHVua25vd24gdHlwZSBuYW1lIKF2YV9saXN0og0KPiANCj4gU2lnbmVkLW9m
Zi1ieTogWGkgV2FuZyA8eGkud2FuZ0BnbWFpbC5jb20+DQoNCkFwcGxpZWQsIHRoYW5rcy4NCg==
