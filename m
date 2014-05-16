From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] e1000: Use
 is_broadcast_ether_addr/is_multicast_ether_addr helpers
Date: Fri, 16 May 2014 17:00:30 -0400 (EDT)
Message-ID: <20140516.170030.149237114732192278.davem@davemloft.net>
References: <1400227238-13428-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49343 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752884AbaEPVAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 17:00:32 -0400
In-Reply-To: <1400227238-13428-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Fri, 16 May 2014 10:00:38 +0200

> Use the is_broadcast_ether_addr/is_multicast_ether_addr helper functions
> from linux/etherdevice.h instead of open coding them.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

I'll let Jeff Kirsher take this via his tree.
