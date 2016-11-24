From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdevice.h: fix kernel-doc warning
Date: Wed, 23 Nov 2016 20:27:02 -0500 (EST)
Message-ID: <20161123.202702.1190966424251782715.davem@davemloft.net>
References: <89f2d6da-89e1-1962-9f6f-e81dece8a101@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rdunlap@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41928 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935508AbcKXB1E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 20:27:04 -0500
In-Reply-To: <89f2d6da-89e1-1962-9f6f-e81dece8a101@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>
Date: Mon, 21 Nov 2016 18:28:36 -0800

> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix kernel-doc warning in <linux/netdevice.h> (missing ':'):
> 
> ..//include/linux/netdevice.h:1904: warning: No description found for parameter 'prio_tc_map[TC_BITMASK + 1]'
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

Applied.
