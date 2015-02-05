From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] pkt_sched: fq: better control of DDOS
 traffic
Date: Wed, 04 Feb 2015 22:17:13 -0800 (PST)
Message-ID: <20150204.221713.2034671818243525224.davem@davemloft.net>
References: <1422626772.21689.90.camel@edumazet-glaptop2.roam.corp.google.com>
	<1422984739.907.25.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423114240.31870.33.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41526 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061AbbBEGRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 01:17:16 -0500
In-Reply-To: <1423114240.31870.33.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Feb 2015 21:30:40 -0800

> This patch adds a new attribute, orphan_mask, that is adding
> possibility of having a stochastic hash for orphaned skb.
 ...
> v3: adding the missing include file change
> v2: make the left shift in fq_classify.

Applied, thanks Eric.
