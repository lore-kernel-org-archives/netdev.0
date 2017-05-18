From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: do not inherit ipv6_{mc|ac|fl}_list from
 parent
Date: Thu, 18 May 2017 10:24:24 -0400 (EDT)
Message-ID: <20170518.102424.703133212160153956.davem@davemloft.net>
References: <1495030600.6465.19.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        andreyknvl@google.com, vyasevich@gmail.com, nhorman@tuxdriver.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43330 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756148AbdEROYZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 10:24:25 -0400
In-Reply-To: <1495030600.6465.19.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 17 May 2017 07:16:40 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> SCTP needs fixes similar to 83eaddab4378 ("ipv6/dccp: do not inherit
> ipv6_mc_list from parent"), otherwise bad things can happen.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>

Applied and queued up for -stable, thanks.
