From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: add tcp_mss_clamp() helper
Date: Fri, 03 Feb 2017 11:19:49 -0500 (EST)
Message-ID: <20170203.111949.1351920811825568342.davem@davemloft.net>
References: <1486051496.13103.48.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38666 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750890AbdBCQTv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 11:19:51 -0500
In-Reply-To: <1486051496.13103.48.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Feb 2017 08:04:56 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Small cleanup factorizing code doing the TCP_MAXSEG clamping.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Nice cleanup, applied, thanks.
