From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-sysfs: get_netdev_queue_index() cleanup
Date: Fri, 14 Feb 2014 15:47:01 -0500 (EST)
Message-ID: <20140214.154701.204137326352984674.davem@davemloft.net>
References: <1392314833.1752.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37775 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751538AbaBNUrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 15:47:04 -0500
In-Reply-To: <1392314833.1752.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 13 Feb 2014 10:07:13 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Remove one inline keyword, and no need for a loop to find
> an index into a table.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
