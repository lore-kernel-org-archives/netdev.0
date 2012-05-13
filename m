From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] etherdevice: Remove now unused
 compare_ether_addr_64bits
Date: Sat, 12 May 2012 23:35:13 -0400 (EDT)
Message-ID: <20120512.233513.1428430627278045925.davem@davemloft.net>
References: <acb363688c8ed729cc61e288605cdb4aa4089149.1336618708.git.joe@perches.com>
	<20120510.233554.263340913611469229.davem@davemloft.net>
	<1336774866.13434.16.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45880 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639Ab2EMDfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2012 23:35:17 -0400
In-Reply-To: <1336774866.13434.16.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri, 11 May 2012 15:21:06 -0700

> Move and invert the logic from the otherwise unused
> compare_ether_addr_64bits to ether_addr_equal_64bits.
> 
> Neaten the logic in is_etherdev_addr.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
