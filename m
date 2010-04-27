From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] cxgb4: set skb->rxhash
Date: Tue, 27 Apr 2010 16:22:50 -0700 (PDT)
Message-ID: <20100427.162250.93454954.davem@davemloft.net>
References: <1272409856-12535-1-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57686
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753184Ab0D0XWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 19:22:45 -0400
In-Reply-To: <1272409856-12535-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Tue, 27 Apr 2010 16:10:56 -0700

> Implement the ->set_flags ethtool method to control NETIF_F_RXHASH and
> set skb->rxhash to the HW calculated hash accordingly.
> 
> Follow Eric Dumazet's suggestion and use the hash value raw.
> 
> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>

Applied, thanks Dimitris.
