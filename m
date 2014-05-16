From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] i40evf: Use is_multicast_ether_addr helper
Date: Fri, 16 May 2014 17:00:38 -0400 (EDT)
Message-ID: <20140516.170038.69306345944763152.davem@davemloft.net>
References: <1400227234-13383-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49350 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048AbaEPVAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 17:00:39 -0400
In-Reply-To: <1400227234-13383-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Fri, 16 May 2014 10:00:34 +0200

> Use the is_multicast_ether_addr helper function from linux/etherdevice.h
> instead of open coding the multicast address check.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Likewise, I'll let Jeff Kirsher take this via his tree.
