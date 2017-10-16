From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/1] tipc: fix rebasing error
Date: Mon, 16 Oct 2017 21:29:49 +0100 (WEST)
Message-ID: <20171016.212949.345880628534508897.davem@davemloft.net>
References: <1508162691-31392-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, parthasarathy.bhuvaragan@ericsson.com,
        ying.xue@windriver.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34814 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754092AbdJPU3u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 16:29:50 -0400
In-Reply-To: <1508162691-31392-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Mon, 16 Oct 2017 16:04:51 +0200

> In commit 2f487712b893 ("tipc: guarantee that group broadcast doesn't
> bypass group unicast") there was introduced a last-minute rebasing
> error that broke non-group communication.
> 
> We fix this here.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.
