From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] gtp: simple gtp improvements
Date: Sun, 29 Jan 2017 13:56:05 -0500 (EST)
Message-ID: <20170129.135605.1273656353031937944.davem@davemloft.net>
References: <20170126152149.3284-1-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netdev@vger.kernel.org,
        Lionel.Gauthier@eurecom.fr, openbsc@lists.osmocom.org,
        laforge@gnumonks.org, elfring@users.sourceforge.net
To: aschultz@tpip.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56080 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751509AbdA2S4m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 13:56:42 -0500
In-Reply-To: <20170126152149.3284-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Schultz <aschultz@tpip.net>
Date: Thu, 26 Jan 2017 16:21:47 +0100

> This is the part of the previous "simple gtp improvements" series
> that Pablo indicated should go into net-next.
> 
> The rcu_lock removal is small correctness changes. Passing invalid
> to user space allows for more standards compliant handling of invalid
> tunnels.

Series applied, thanks.
