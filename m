From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: remove unneeded check to pskb_may_pull in
 ipip6_rcv
Date: Fri, 18 Jan 2013 14:44:40 -0500 (EST)
Message-ID: <20130118.144440.265154252143594884.davem@davemloft.net>
References: <20130118191816.GA4795@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38957 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751905Ab3ARTol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 14:44:41 -0500
In-Reply-To: <20130118191816.GA4795@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 18 Jan 2013 20:18:17 +0100

> This is already checked by the caller (tunnel64_rcv) and brings ipip6_rcv
> in line with ipip_rcv.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied to net-next, thanks.
