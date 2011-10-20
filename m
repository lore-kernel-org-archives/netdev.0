From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] igb: fix a compile warning
Date: Thu, 20 Oct 2011 17:09:59 -0400 (EDT)
Message-ID: <20111020.170959.914587368243025974.davem@davemloft.net>
References: <1319014355-15678-1-git-send-email-roy.qing.li@gmail.com>
	<43F901BD926A4E43B106BF17856F075501A1776E6B@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753031Ab1JTVKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 17:10:05 -0400
In-Reply-To: <43F901BD926A4E43B106BF17856F075501A1776E6B@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogIlJvc2UsIEdyZWdvcnkgViIgPGdyZWdvcnkudi5yb3NlQGludGVsLmNvbT4NCkRhdGU6
IFdlZCwgMTkgT2N0IDIwMTEgMDk6Mjg6NTQgLTA3MDANCg0KPj4gLS0tLS1PcmlnaW5hbCBNZXNz
YWdlLS0tLS0NCj4+IEZyb206IG5ldGRldi1vd25lckB2Z2VyLmtlcm5lbC5vcmcgW21haWx0bzpu
ZXRkZXYtb3duZXJAdmdlci5rZXJuZWwub3JnXQ0KPj4gT24gQmVoYWxmIE9mIHJveS5xaW5nLmxp
QGdtYWlsLmNvbQ0KPj4gU2VudDogV2VkbmVzZGF5LCBPY3RvYmVyIDE5LCAyMDExIDE6NTMgQU0N
Cj4+IFRvOiBuZXRkZXZAdmdlci5rZXJuZWwub3JnDQo+PiBTdWJqZWN0OiBbUEFUQ0ggbmV0LW5l
eHRdIGlnYjogZml4IGEgY29tcGlsZSB3YXJuaW5nDQo+PiANCj4+IEZyb206IFJvbmdRaW5nIExp
IDxyb3kucWluZy5saUBnbWFpbC5jb20+DQo+PiANCj4+IGNvbnRyb2wgdGhlc2UgdGhyZWUgZnVu
Y3Rpb24gZGVjbGFyYXRpb25zIGFuZA0KPj4gZGVmaW5pdGlvbnMgd2l0aCBzYW1lIG1hY3JvIENP
TkZJR19QQ0lfSU9WDQo+PiANCj4+IGRyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2lnYi9pZ2Jf
bWFpbi5jOjE2NToNCj4+IHdhcm5pbmc6IOKAmGlnYl92Zl9jb25maWd1cmXigJkgZGVjbGFyZWQg
4oCYc3RhdGlj4oCZIGJ1dCBuZXZlciBkZWZpbmVkDQo+PiBkcml2ZXJzL25ldC9ldGhlcm5ldC9p
bnRlbC9pZ2IvaWdiX21haW4uYzoxNjY6DQo+PiB3YXJuaW5nOiDigJhpZ2JfZmluZF9lbmFibGVk
X3Zmc+KAmSBkZWNsYXJlZCDigJhzdGF0aWPigJkgYnV0IG5ldmVyIGRlZmluZWQNCj4+IGRyaXZl
cnMvbmV0L2V0aGVybmV0L2ludGVsL2lnYi9pZ2JfbWFpbi5jOjE2NzoNCj4+IHdhcm5pbmc6IOKA
mGlnYl9jaGVja192Zl9hc3NpZ25tZW504oCZIGRlY2xhcmVkIOKAmHN0YXRpY+KAmSBidXQgbmV2
ZXIgZGVmaW5lZA0KPj4gDQo+PiBTaWduZWQtb2ZmLWJ5OiBSb25nUWluZyBMaSA8cm95LnFpbmcu
bGlAZ21haWwuY29tPg0KPiANCj4gQWNrZWQtYnk6IEdyZWcgUm9zZSA8Z3JlZ29yeS52LnJvc2VA
aW50ZWwuY29tPg0KDQpBcHBsaWVkLCB0aGFua3MuDQo=
