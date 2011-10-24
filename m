From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cls_flow: Add tunnel support to the flow classifier
Date: Mon, 24 Oct 2011 18:36:40 -0400 (EDT)
Message-ID: <20111024.183640.270445902457677669.davem@davemloft.net>
References: <1319419287.20602.21.camel@ganymede>
	<1319426081.2517.20.camel@edumazet-laptop>
	<1319428781.2517.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan@coverfire.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51114 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753486Ab1JXWgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 18:36:46 -0400
In-Reply-To: <1319428781.2517.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 24 Oct 2011 05:59:41 +0200

> [PATCH net-next] net_sched: cls_flow: use skb_header_pointer()
> 
> Dan Siemon would like to add tunnelling support to cls_flow
> 
> This preliminary patch introduces use of skb_header_pointer() to help
> this task, while avoiding skb head reallocation because of deep packet
> inspection.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
