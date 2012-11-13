From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: setsockopt(IPIPPROTO_IPV6,IPV6_MINHOPCOUNT)
 forgot to set return value
Date: Tue, 13 Nov 2012 14:39:30 -0500 (EST)
Message-ID: <20121113.143930.997118479094382961.davem@davemloft.net>
References: <20121111055234.GA28043@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48414 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969Ab2KMTjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 14:39:32 -0500
In-Reply-To: <20121111055234.GA28043@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sun, 11 Nov 2012 06:52:34 +0100

> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
