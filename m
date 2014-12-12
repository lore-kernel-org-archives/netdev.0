From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vlan: Add ability to always enable TSO/UFO
Date: Fri, 12 Dec 2014 11:01:02 -0500 (EST)
Message-ID: <20141212.110102.778188055200622888.davem@davemloft.net>
References: <1418179394-4470-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932586AbaLLQBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 11:01:04 -0500
In-Reply-To: <1418179394-4470-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Wed, 10 Dec 2014 11:43:13 +0900

> Since the real device can segment packets by software, a vlan device
> can set TSO/UFO even when the real device doesn't have those features.
> Unlike GSO, this allows packets to be segmented after Qdisc.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Applied.
