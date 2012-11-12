From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] kaweth:BQL support
Date: Mon, 12 Nov 2012 02:59:47 -0500 (EST)
Message-ID: <20121112.025947.2290126757565589839.davem@davemloft.net>
References: <1352463587-23899-1-git-send-email-oliver@neukum.org>
	<1352466944.19779.556.camel@edumazet-glaptop>
	<5350156.Kb3Hv9rKLR@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182Ab2KLH7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 02:59:51 -0500
In-Reply-To: <5350156.Kb3Hv9rKLR@linux-lqwf.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oliver@neukum.org>
Date: Mon, 12 Nov 2012 08:38:57 +0100

> On Friday 09 November 2012 05:15:44 Eric Dumazet wrote:
>> I am curious to know if it changes anything on the behavior of this
>> network adapter ?
>> 
>> Because it seems queue is stopped anyway when a packet is in transmit.
> 
> True, I'd need to also do more changes on the tx path.
> 
> Dave, for now please disregard the patch.

Ok.
