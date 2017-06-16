From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Request for -stable inclusion (xt_TCPMSS)
Date: Fri, 16 Jun 2017 09:45:17 +0200
Message-ID: <20170616074516.yzgd7sqqigjepx37@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Denys Fedoryshchenko <nuclearcat@nuclearcat.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:51157 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752534AbdFPHpU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 03:45:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Please queue 2638fd0f92d4 ("netfilter: xt_TCPMSS: add more sanity tests on tcph->doff")
for -stable.
It fixes hard to debug crashes in production, that can be triggered by
remote peers.

Regards,

Guillaume
