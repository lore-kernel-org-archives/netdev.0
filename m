From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: BUG (NULL ptr dereference in ipv4_dst_check)
Date: Wed, 03 Aug 2011 03:34:42 -0700 (PDT)
Message-ID: <20110803.033442.1456080508068739176.davem@davemloft.net>
References: <20110729.081902.300678107767426313.davem@davemloft.net>
	<1311954208.2843.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1312002053.2873.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: synapse@hippy.csoma.elte.hu, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43811 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753872Ab1HCKex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 06:34:53 -0400
In-Reply-To: <1312002053.2873.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 30 Jul 2011 07:00:53 +0200

> [PATCH] net: fix NULL dereferences in check_peer_redir()

I'm adding this now to my tree so it gets more widespread
testing.

Thanks Eric.
