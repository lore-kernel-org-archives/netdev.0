From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: eliminate uninitialized variable warning
Date: Wed, 15 Jun 2016 21:47:53 -0700 (PDT)
Message-ID: <20160615.214753.1495067872315615538.davem@davemloft.net>
References: <1465971091-16695-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: jon.maloy@ericsson.com, erik.hugne@gmail.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36548 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588AbcFPEry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 00:47:54 -0400
In-Reply-To: <1465971091-16695-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogWWluZyBYdWUgPHlpbmcueHVlQHdpbmRyaXZlci5jb20+DQpEYXRlOiBXZWQsIDE1IEp1
biAyMDE2IDE0OjExOjMxICswODAwDQoNCj4gbmV0L3RpcGMvbGluay5jOiBJbiBmdW5jdGlvbiCh
dGlwY19saW5rX3RpbWVvdXSiOg0KPiBuZXQvdGlwYy9saW5rLmM6NzQ0OjI4OiB3YXJuaW5nOiCh
bXR5cKIgbWF5IGJlIHVzZWQgdW5pbml0aWFsaXplZCBpbiB0aGlzIGZ1bmN0aW9uIFstV3VuaW5p
dGlhbGl6ZWRdDQo+IA0KPiBGaXhlczogNDJiMThmNjA1ZmVhICgidGlwYzogcmVmYWN0b3IgZnVu
Y3Rpb24gdGlwY19saW5rX3RpbWVvdXQoKSIpDQo+IEFja2VkLWJ5OiBKb24gTWFsb3kgPGpvbi5t
YWxveUBlcmljc3Nvbi5jb20+DQo+IFNpZ25lZC1vZmYtYnk6IFlpbmcgWHVlIDx5aW5nLnh1ZUB3
aW5kcml2ZXIuY29tPg0KDQpBcHBsaWVkLg0K
