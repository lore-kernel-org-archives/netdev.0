From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: use ktime_get_ns() and
 ktime_get_real_ns() helpers
Date: Fri, 22 Aug 2014 19:57:36 -0700 (PDT)
Message-ID: <20140822.195736.819878528885106514.davem@davemloft.net>
References: <1408757529.5604.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56953 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822AbaHWC5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 22:57:37 -0400
In-Reply-To: <1408757529.5604.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 22 Aug 2014 18:32:09 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> ktime_get_ns() replaces ktime_to_ns(ktime_get())
> 
> ktime_get_real_ns() replaces ktime_to_ns(ktime_get_real())
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
