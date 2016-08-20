From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: include addrconf.h
Date: Fri, 19 Aug 2016 17:08:10 -0700 (PDT)
Message-ID: <20160819.170810.8982720393798959.davem@davemloft.net>
References: <1471539552.29842.69.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55961 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755534AbcHTAId (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 20:08:33 -0400
In-Reply-To: <1471539552.29842.69.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 18 Aug 2016 09:59:12 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Include ipv4_rcv_saddr_equal() definition to avoid this sparse error :
> 
> net/ipv4/udp.c:362:5: warning: symbol 'ipv4_rcv_saddr_equal' was not
> declared. Should it be static?
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
