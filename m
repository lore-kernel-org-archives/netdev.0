From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: fix qdisc_pkt_len_init()
Date: Wed, 16 Jan 2013 00:41:41 -0500 (EST)
Message-ID: <20130116.004141.1061388869492706897.davem@davemloft.net>
References: <1358313261.19956.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yuvalmin@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55461 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877Ab3APFmG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 00:42:06 -0500
In-Reply-To: <1358313261.19956.12.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Jan 2013 21:14:21 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 1def9238d4aa2 (net_sched: more precise pkt_len computation)
> does a wrong computation of mac + network headers length, as it includes
> the padding before the frame.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yuval Mintz <yuvalmin@broadcom.com>

Applied.
