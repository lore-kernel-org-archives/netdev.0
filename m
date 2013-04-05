From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] atl1e: limit gso segment size to prevent
 generation of wrong ip length fields
Date: Fri, 05 Apr 2013 00:49:49 -0400 (EDT)
Message-ID: <20130405.004949.1039065624607918197.davem@davemloft.net>
References: <20130403003646.GJ4924@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53464 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932520Ab3DEEtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 00:49:50 -0400
In-Reply-To: <20130403003646.GJ4924@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 3 Apr 2013 02:36:46 +0200

> The limit of 0x3c00 is taken from the windows driver.
> 
> Suggested-by: Huang, Xiong <xiong@qca.qualcomm.com>
> Cc: Huang, Xiong <xiong@qca.qualcomm.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks!
