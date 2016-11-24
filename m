From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: enhance tcp_collapse_retrans() with
 skb_shift()
Date: Thu, 24 Nov 2016 15:42:08 -0500 (EST)
Message-ID: <20161124.154208.1594403474025352610.davem@davemloft.net>
References: <1479243110.8455.135.camel@edumazet-glaptop3.roam.corp.google.com>
        <1479841053.8455.441.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41122 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933914AbcKXUmK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 15:42:10 -0500
In-Reply-To: <1479841053.8455.441.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Nov 2016 10:57:33 -0800

> David, patch is marked 'Superseded' in
> https://patchwork.ozlabs.org/patch/695264/
> 
> Not sure what this means exactly ?
> Did I miss a mail/feedback/something ?

I must have mistakenly marked it that way, sorry.

Applied to net-next, thanks Eric.
