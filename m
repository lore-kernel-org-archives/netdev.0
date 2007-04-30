From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5 2.6.21-rc7] skb: introduce skb_queue_walk_safe()
Date: Mon, 30 Apr 2007 00:07:41 -0700 (PDT)
Message-ID: <20070430.000741.99733799.davem@davemloft.net>
References: <200704231601.l3NG13pH030160@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57176
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423096AbXD3HHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 03:07:44 -0400
In-Reply-To: <200704231601.l3NG13pH030160@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Chapman <jchapman@katalix.com>
Date: Mon, 23 Apr 2007 17:01:03 +0100

> [SKB]: Introduce skb_queue_walk_safe()
> 
> This patch provides a method for walking skb lists while inserting or
> removing skbs from the list.
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>

Applied, thanks.
