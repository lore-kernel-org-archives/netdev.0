From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/4] udp: receive path optimizations
Date: Fri, 09 Dec 2016 22:13:09 -0500 (EST)
Message-ID: <20161209.221309.454851040879529821.davem@davemloft.net>
References: <1481226117-31288-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pabeni@redhat.com, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39560 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751631AbcLJDNQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 22:13:16 -0500
In-Reply-To: <1481226117-31288-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Thu,  8 Dec 2016 11:41:53 -0800

> This patch series provides about 100 % performance increase under flood. 
> 
> v2: added Paolo feedback on udp_rmem_release() for tiny sk_rcvbuf
>     added the last patch touching sk_rmem_alloc later

Series applied, thanks.
