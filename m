From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 1/6] net: allow > 0 order atomic page alloc
 in skb_page_frag_refill
Date: Thu, 16 Jan 2014 15:30:20 -0800 (PST)
Message-ID: <20140116.153020.587523865163482894.davem@davemloft.net>
References: <1389901950-3854-1-git-send-email-mwdalton@google.com>
	<20140116.152800.901405996505782677.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, edumazet@google.com, rusty@rustcorp.com.au,
	mst@redhat.com, jasowang@redhat.com, bhutchings@solarflare.com,
	virtualization@lists.linux-foundation.org
To: mwdalton@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54870 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850AbaAPXaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 18:30:21 -0500
In-Reply-To: <20140116.152800.901405996505782677.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVGh1LCAxNiBK
YW4gMjAxNCAxNToyODowMCAtMDgwMCAoUFNUKQ0KDQo+IEFsbCA2IHBhdGNoZXMgYXBwbGllZC4N
Cg0KQWN0dWFsbHksIEkgcmV2ZXJ0ZWQsIHBsZWFzZSByZXN1Ym1pdCB0aGlzIHNlcmllcyB3aXRo
IHRoZSBmb2xsb3dpbmcNCmJ1aWxkIHdhcm5pbmcgY29ycmVjdGVkOg0KDQpuZXQvY29yZS9uZXQt
c3lzZnMuYzogSW4gZnVuY3Rpb24goXJ4X3F1ZXVlX2FkZF9rb2JqZWN0ojoNCm5ldC9jb3JlL25l
dC1zeXNmcy5jOjc2NzoyMTogd2FybmluZzogaWdub3JpbmcgcmV0dXJuIHZhbHVlIG9mIKFzeXNm
c19jcmVhdGVfZ3JvdXCiLCBkZWNsYXJlZCB3aXRoIGF0dHJpYnV0ZSB3YXJuX3VudXNlZF9yZXN1
bHQgWy1XdW51c2VkLXJlc3VsdF0NCg0KVGhhbmtzLg0K
