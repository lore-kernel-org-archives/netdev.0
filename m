From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: md5: remove tcp_md5_hash_header()
Date: Fri, 19 Aug 2016 17:08:59 -0700 (PDT)
Message-ID: <20160819.170859.2245197609621190445.davem@davemloft.net>
References: <1471538995.29842.65.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55972 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755815AbcHTAJA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 20:09:00 -0400
In-Reply-To: <1471538995.29842.65.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 18 Aug 2016 09:49:55 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> After commit 19689e38eca5 ("tcp: md5: use kmalloc() backed scratch
> areas") this function is no longer used.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
