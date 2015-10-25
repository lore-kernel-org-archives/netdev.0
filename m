From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next] tipc: tipc_link_is_active() can be static
Date: Sun, 25 Oct 2015 06:33:18 -0700 (PDT)
Message-ID: <20151025.063318.1572658873317450844.davem@davemloft.net>
References: <201510242340.mc7bt8l1%fengguang.wu@intel.com>
	<20151024151100.GA46525@lkp-hsx03>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: kbuild-internal@linux.intel.com, lkp@eclists.intel.com,
	kbuild-all@01.org, netdev@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51897 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbbJYNQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2015 09:16:48 -0400
In-Reply-To: <20151024151100.GA46525@lkp-hsx03>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbToga2J1aWxkIHRlc3Qgcm9ib3QgPGZlbmdndWFuZy53dUBpbnRlbC5jb20+DQpEYXRlOiBT
YXQsIDI0IE9jdCAyMDE1IDIzOjExOjAwICswODAwDQoNCj4gVE86ICJEYXZpZCBTLiBNaWxsZXIi
IDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KPiBDQzogbmV0ZGV2QHZnZXIua2VybmVsLm9yZw0KPiBD
QzogSm9uIE1hbG95IDxqb24ubWFsb3lAZXJpY3Nzb24uY29tPg0KPiBDQzogWWluZyBYdWUgPHlp
bmcueHVlQHdpbmRyaXZlci5jb20+DQo+IENDOiB0aXBjLWRpc2N1c3Npb25AbGlzdHMuc291cmNl
Zm9yZ2UubmV0DQo+IENDOiBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnDQo+IA0KPiANCj4g
U2lnbmVkLW9mZi1ieTogRmVuZ2d1YW5nIFd1IDxmZW5nZ3Vhbmcud3VAaW50ZWwuY29tPg0KDQpX
aHkgZG9lc24ndCB0aGUga2J1aWxkIHJvYm90IHJ1biBvbiBpdCdzIG93biBjaGFuZ2VzPyA6LS8N
Cg0KICBDQyBbTV0gIG5ldC90aXBjL2xpbmsubw0KbmV0L3RpcGMvbGluay5jOjE3NjoxMjogd2Fy
bmluZzogoXRpcGNfbGlua19pc19hY3RpdmWiIGRlZmluZWQgYnV0IG5vdCB1c2VkIFstV3VudXNl
ZC1mdW5jdGlvbl0NCg==
