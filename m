From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: unlock busylock before servicing qdisc
Date: Thu, 28 Jun 2012 16:48:56 -0700 (PDT)
Message-ID: <20120628.164856.512764559252947951.davem@davemloft.net>
References: <1340911362.13187.183.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tparkin@katalix.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57525 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab2F1Xs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 19:48:59 -0400
In-Reply-To: <1340911362.13187.183.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 28 Jun 2012 21:22:42 +0200

> @@ -2412,13 +2412,13 @@ static inline int __dev_xmit_skb(struct sk_buff
> *skb, struct Qdisc *q,

Looks like your email client clobbered this, please resubmit.

Thanks.
