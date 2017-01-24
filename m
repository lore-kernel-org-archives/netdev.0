From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v1 0/6] topology server fixes for nametable soft
 lockup
Date: Tue, 24 Jan 2017 16:16:20 -0500 (EST)
Message-ID: <20170124.161620.1168817531666473968.davem@davemloft.net>
References: <1485259248-21812-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
        jon.maloy@ericsson.com, ying.xue@windriver.com
To: parthasarathy.bhuvaragan@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33552 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750930AbdAXVQW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:16:22 -0500
In-Reply-To: <1485259248-21812-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Date: Tue, 24 Jan 2017 13:00:42 +0100

> In this series, we revert the commit 333f796235a527 ("tipc: fix a
> race condition leading to subscriber refcnt bug") and provide an
> alternate solution to fix the race conditions in commits 2-4.
> 
> We have to do this as the above commit introduced a nametbl soft
> lockup at module exit as described by patch#4.

Series applied, thanks.
