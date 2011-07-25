From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] acenic: use netdev_alloc_skb_ip_align
Date: Mon, 25 Jul 2011 16:16:10 -0700 (PDT)
Message-ID: <20110725.161610.528107310628726787.davem@davemloft.net>
References: <1311312533.3886.2.camel@edumazet-laptop>
	<20110721.232501.1187843432422240228.davem@davemloft.net>
	<20110722093112.4caa39e7@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33443 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726Ab1GYXQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 19:16:13 -0400
In-Reply-To: <20110722093112.4caa39e7@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 22 Jul 2011 09:31:12 -0700

> Take Eric's patch one step further.
> Use netdev_skb_ip_align to do setup the receive skb.
> Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
