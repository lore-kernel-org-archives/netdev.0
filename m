From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4: trust shinfo->gso_segs
Date: Thu, 06 Apr 2017 13:28:12 -0700 (PDT)
Message-ID: <20170406.132812.341838195644847391.davem@davemloft.net>
References: <1491407342.10124.51.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com, saeedm@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37734 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751180AbdDFU2O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 16:28:14 -0400
In-Reply-To: <1491407342.10124.51.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 05 Apr 2017 08:49:02 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> mlx4 is the only driver in the tree making a point to recompute
> shinfo->gso_segs.
> 
> Lets remove superfluous code.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
