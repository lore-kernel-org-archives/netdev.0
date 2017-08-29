From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove dmaengine.h inclusion from netdevice.h
Date: Tue, 29 Aug 2017 16:10:22 -0700 (PDT)
Message-ID: <20170829.161022.175496467890687470.davem@davemloft.net>
References: <150403787157.72820.10644938115323539701.stgit@djiang5-desk3.ch.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dave.jiang@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41148 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751449AbdH2XKX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 19:10:23 -0400
In-Reply-To: <150403787157.72820.10644938115323539701.stgit@djiang5-desk3.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jiang <dave.jiang@intel.com>
Date: Tue, 29 Aug 2017 13:17:51 -0700

> Since the removal of NET_DMA, dmaengine.h header file shouldn't be needed
> by netdevice.h anymore.
> 
> Signed-off-by: Dave Jiang <dave.jiang@intel.com>

Applied to net-next, but it would have been really great for you to
have provided a proper "Fixes: " tag referencing the NET_DMA
removal change.

Thanks.
