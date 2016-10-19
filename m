From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: do not export sysctl_tcp_low_latency
Date: Wed, 19 Oct 2016 11:14:04 -0400 (EDT)
Message-ID: <20161019.111404.1958411740360809893.davem@davemloft.net>
References: <1476822247.5650.72.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56562 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S943454AbcJSPOG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 11:14:06 -0400
In-Reply-To: <1476822247.5650.72.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 18 Oct 2016 13:24:07 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Since commit b2fb4f54ecd4 ("tcp: uninline tcp_prequeue()") we no longer
> access sysctl_tcp_low_latency from a module.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
