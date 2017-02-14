From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: busy-poll: remove LL_FLUSH_FAILED and
 LL_FLUSH_BUSY
Date: Mon, 13 Feb 2017 22:01:03 -0500 (EST)
Message-ID: <20170213.220103.1689372921636040210.davem@davemloft.net>
References: <1486734406.7793.142.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55180 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750943AbdBNDBI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 22:01:08 -0500
In-Reply-To: <1486734406.7793.142.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 10 Feb 2017 05:46:46 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 79e7fff47b7b ("net: remove support for per driver
> ndo_busy_poll()") made them obsolete.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
