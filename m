From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] s390/net: more updates for 4.14
Date: Fri, 18 Aug 2017 10:22:03 -0700 (PDT)
Message-ID: <20170818.102203.156780357331879436.davem@davemloft.net>
References: <20170818081910.48869-1-jwi@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: jwi@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56882 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750949AbdHRRWE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 13:22:04 -0400
In-Reply-To: <20170818081910.48869-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Date: Fri, 18 Aug 2017 10:19:03 +0200

> please apply another batch of qeth patches for net-next.
> This reworks the xmit path for L2 OSAs to use skb_cow_head() instead of
> skb_realloc_headroom().

Series applied, thanks Julian.
