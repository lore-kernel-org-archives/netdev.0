From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sch_choke: use skb_flow_dissect()
Date: Tue, 29 Nov 2011 13:23:49 -0500 (EST)
Message-ID: <20111129.132349.248574068074453516.davem@davemloft.net>
References: <1322576535.2465.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41799 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755969Ab1K2SXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 13:23:53 -0500
In-Reply-To: <1322576535.2465.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 29 Nov 2011 15:22:15 +0100

> Instead of using a custom flow dissector, use skb_flow_dissect() and
> benefit from tunnelling support.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
