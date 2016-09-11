From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Revert "hv_netvsc: make inline functions
 static"
Date: Sat, 10 Sep 2016 21:23:14 -0700 (PDT)
Message-ID: <20160910.212314.1230001135969536194.davem@davemloft.net>
References: <1473450324-25918-1-git-send-email-sthemmin@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, netdev@vger.kernel.org
To: sthemmin@microsoft.com, sthemmin@exchange.microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51364 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751128AbcIKEXP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Sep 2016 00:23:15 -0400
In-Reply-To: <1473450324-25918-1-git-send-email-sthemmin@exchange.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sthemmin@exchange.microsoft.com
Date: Fri,  9 Sep 2016 12:45:24 -0700

> From: Stephen Hemminger <sthemmin@microsoft.com>
> 
> These functions are used by other code misc-next tree.
> 
> This reverts commit 30d1de08c87ddde6f73936c3350e7e153988fe02.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied.
