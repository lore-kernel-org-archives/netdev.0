From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r6040: fix check against MCRO_HASHEN bit in
 r6040_multicast_list
Date: Wed, 16 Nov 2011 20:35:08 -0500 (EST)
Message-ID: <20111116.203508.653539472804307546.davem@davemloft.net>
References: <1321459208-28463-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754910Ab1KQBfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 20:35:13 -0500
In-Reply-To: <1321459208-28463-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Wed, 16 Nov 2011 17:00:08 +0100

> We are checking whether the MCR0_HASHEN bit is set using a logical and
> instead of bitwise and, fix that.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied, thank you.
