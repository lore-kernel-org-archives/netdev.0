From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: add NUMA awareness to
 seg6_hmac_init_algo()
Date: Sun, 22 Jan 2017 16:50:59 -0500 (EST)
Message-ID: <20170122.165059.1514590451993712982.davem@davemloft.net>
References: <1484928536.16328.127.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.lebrun@uclouvain.be
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56084 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdAVVvB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 16:51:01 -0500
In-Reply-To: <1484928536.16328.127.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Jan 2017 08:08:56 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Since we allocate per cpu storage, let's also use NUMA hints.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
