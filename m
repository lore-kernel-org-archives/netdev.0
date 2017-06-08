From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] tcp: Namespaceify 3 sysctls
Date: Thu, 08 Jun 2017 10:53:47 -0400 (EDT)
Message-ID: <20170608.105347.994227555967850443.davem@davemloft.net>
References: <20170607173439.17092-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57720 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751601AbdFHOxt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 10:53:49 -0400
In-Reply-To: <20170607173439.17092-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Wed,  7 Jun 2017 10:34:35 -0700

> Move tcp_sack, tcp_window_scaling and tcp_timestamps
> sysctls to network namespaces.
> 
> Eric Dumazet (4):
>   tcp: add a struct net parameter to tcp_parse_options()
>   tcp: Namespaceify sysctl_tcp_sack
>   tcp: Namespaceify sysctl_tcp_window_scaling
>   tcp: Namespaceify sysctl_tcp_timestamps

Series applied, thanks Eric.
