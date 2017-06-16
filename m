From: David Miller <davem@davemloft.net>
Subject: Re: Request for -stable inclusion (xt_TCPMSS)
Date: Fri, 16 Jun 2017 12:10:41 -0400 (EDT)
Message-ID: <20170616.121041.1690932428093762139.davem@davemloft.net>
References: <20170616074516.yzgd7sqqigjepx37@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, nuclearcat@nuclearcat.com,
        pablo@netfilter.org, netdev@vger.kernel.org
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60910 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbdFPQKn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 12:10:43 -0400
In-Reply-To: <20170616074516.yzgd7sqqigjepx37@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Fri, 16 Jun 2017 09:45:17 +0200

> Hi David,
> 
> Please queue 2638fd0f92d4 ("netfilter: xt_TCPMSS: add more sanity tests on tcph->doff")
> for -stable.
> It fixes hard to debug crashes in production, that can be triggered by
> remote peers.

Pablo handles netfilter -stable submissions, so please ask him.

Thank you.
