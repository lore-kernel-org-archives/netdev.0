From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: fix compile warnings in
 sctp_tsnmap_num_gabs
Date: Sun, 20 Feb 2011 11:10:46 -0800 (PST)
Message-ID: <20110220.111046.183035150.davem@davemloft.net>
References: <4D60C966.2000302@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: vladislav.yasevich@hp.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42352
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754640Ab1BTTKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 14:10:10 -0500
In-Reply-To: <4D60C966.2000302@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogU2hhbiBXZWkgPHNoYW53ZWlAY24uZnVqaXRzdS5jb20+DQpEYXRlOiBTdW4sIDIwIEZl
YiAyMDExIDE1OjU3OjI2ICswODAwDQoNCj4gbmV0L3NjdHAvdHNubWFwLmM6IEluIGZ1bmN0aW9u
IKFzY3RwX3Rzbm1hcF9udW1fZ2Fic6I6DQo+IG5ldC9zY3RwL3Rzbm1hcC5jOjM0Nzogd2Fybmlu
ZzogoXN0YXJ0oiBtYXkgYmUgdXNlZCB1bmluaXRpYWxpemVkIGluIHRoaXMgZnVuY3Rpb24NCj4g
bmV0L3NjdHAvdHNubWFwLmM6MzQ3OiB3YXJuaW5nOiChZW5koiBtYXkgYmUgdXNlZCB1bmluaXRp
YWxpemVkIGluIHRoaXMgZnVuY3Rpb24NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IFNoYW4gV2VpIDxz
aGFud2VpQGNuLmZ1aml0c3UuY29tPg0KDQpBcHBsaWVkLg0K
