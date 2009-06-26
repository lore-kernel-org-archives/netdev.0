From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] rcu_barrier: Resubmitting the the networking bits
Date: Fri, 26 Jun 2009 13:52:20 -0700 (PDT)
Message-ID: <20090626.135220.246454927.davem@davemloft.net>
References: <20090626204152.10664.69628.stgit@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hawk@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55456
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750943AbZFZUwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 16:52:15 -0400
In-Reply-To: <20090626204152.10664.69628.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <hawk@comx.dk>
Date: Fri, 26 Jun 2009 22:45:43 +0200

> This patchset is a resubmit of the network related part of a patchseries
> titled "We must use rcu_barrier() on module unload".  Just to make it
> easier for DaveM to pick it up.
> 
> If an unloadable module uses RCU callbacks, it need to use
> rcu_barrier() so that the module may be safely unloaded.

All applied, thanks a lot!
