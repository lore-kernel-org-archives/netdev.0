From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] net sched filters: pass netlink message flags
 in event notification
Date: Thu, 17 Nov 2016 13:42:41 -0500 (EST)
Message-ID: <20161117.134241.295313763451189861.davem@davemloft.net>
References: <1479334570-25159-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: mrv@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41356 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754638AbcKQSmm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 13:42:42 -0500
In-Reply-To: <1479334570-25159-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Mashak <mrv@mojatatu.com>
Date: Wed, 16 Nov 2016 17:16:10 -0500

> Userland client should be able to read an event, and reflect it back to
> the kernel, therefore it needs to extract complete set of netlink flags.
> 
> For example, this will allow "tc monitor" to distinguish Add and Replace
> operations.
> 
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Looks good, applied.
