From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cgxb4: Stop using ethtool SPEED_* constants
Date: Mon, 24 Feb 2014 19:04:35 -0500 (EST)
Message-ID: <20140224.190435.1574600104753243481.davem@davemloft.net>
References: <1393113804.6823.21.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dm@chelsio.com, kumaras@chelsio.com, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48508 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639AbaBYAEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 19:04:37 -0500
In-Reply-To: <1393113804.6823.21.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 23 Feb 2014 00:03:24 +0000

> ethtool speed values are just numbers of megabits and there is no need
> to add SPEED_40000.  To be consistent, use integer constants directly
> for all speeds.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied, thanks Ben.
