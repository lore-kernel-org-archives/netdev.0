From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: add knob to send unsolicited ND on link-layer
 address change
Date: Tue, 13 Nov 2012 14:29:36 -0500 (EST)
Message-ID: <20121113.142936.942170251981578218.davem@davemloft.net>
References: <20121107024620.GD26398@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48244 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754731Ab2KMT3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 14:29:38 -0500
In-Reply-To: <20121107024620.GD26398@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 7 Nov 2012 03:46:20 +0100

> This patch introduces a new knob ndisc_notify. If enabled, the kernel
> will transmit an unsolicited neighbour advertisement on link-layer address
> change to update the neighbour tables of the corresponding hosts more quickly.
> 
> This is the equivalent to arp_notify in ipv4 world.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied to net-next, with the empty line removed.

Thanks.
