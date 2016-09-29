From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: do not export sk_stream_write_space
Date: Wed, 28 Sep 2016 20:33:01 -0400 (EDT)
Message-ID: <20160928.203301.1149907305837506133.davem@davemloft.net>
References: <1475077276.28155.108.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43108 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750719AbcI2AdK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 20:33:10 -0400
In-Reply-To: <1475077276.28155.108.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 28 Sep 2016 08:41:16 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Since commit 900f65d361d3 ("tcp: move duplicate code from
> tcp_v4_init_sock()/tcp_v6_init_sock()") we no longer need
> to export sk_stream_write_space()
> 
> From: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
