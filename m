From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2] 8139too: Add 64bit statistics
Date: Tue, 06 Mar 2012 00:05:33 -0500 (EST)
Message-ID: <20120306.000533.1858956415842038668.davem@davemloft.net>
References: <20120305113353.GA12969@Spy32>
	<1330954326.2474.9.camel@edumazet-laptop>
	<20120306031301.GA4516@Spy32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, greearb@candelatech.com,
	adobriyan@gmail.com, jasowang@redhat.com, joe@perches.com,
	netdev@vger.kernel.org
To: junchangwang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59572 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710Ab2CFFFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 00:05:43 -0500
In-Reply-To: <20120306031301.GA4516@Spy32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Junchang Wang <junchangwang@gmail.com>
Date: Tue, 6 Mar 2012 11:13:05 +0800

> 
> Switch to use ndo_get_stats64 to get 64bit statistics.
> Two sync entries are used (one for Rx and one for Tx).
> 
> Signed-off-by: Junchang Wang <junchangwang@gmail.com>

Applied, thanks.
