From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: Request for -stable inclusion (xt_TCPMSS)
Date: Fri, 16 Jun 2017 11:59:12 +0200
Message-ID: <20170616095912.GB1963@salvia>
References: <20170616074516.yzgd7sqqigjepx37@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Denys Fedoryshchenko <nuclearcat@nuclearcat.com>,
        netdev@vger.kernel.org
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59722 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753249AbdFPJ7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Jun 2017 05:59:16 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 9E488E1243
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 11:59:05 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 8EE4F102184
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 11:59:05 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 86B6FA5B4
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 11:59:03 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20170616074516.yzgd7sqqigjepx37@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Guillaume,

On Fri, Jun 16, 2017 at 09:45:17AM +0200, Guillaume Nault wrote:
> Hi David,
> 
> Please queue 2638fd0f92d4 ("netfilter: xt_TCPMSS: add more sanity tests on tcph->doff")
> for -stable.
> It fixes hard to debug crashes in production, that can be triggered by
> remote peers.

What stable kernels you want this in? Does this apply cleanly to them
all?

I can route this for you directly to stable@vger.kernel.org once we
sort out these questions.

Thanks!
