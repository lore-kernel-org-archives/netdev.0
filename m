From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fix a sparse warning
Date: Mon, 18 Feb 2013 15:28:20 -0500 (EST)
Message-ID: <20130218.152820.2147008016140090036.davem@davemloft.net>
References: <1361218732.19353.105.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: erdnetdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49503 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754543Ab3BRU2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 15:28:21 -0500
In-Reply-To: <1361218732.19353.105.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <erdnetdev@gmail.com>
Date: Mon, 18 Feb 2013 12:18:52 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> net/ipv6/reassembly.c:82:72: warning: incorrect type in argument 3 (different base types)
> net/ipv6/reassembly.c:82:72:    expected unsigned int [unsigned] [usertype] c
> net/ipv6/reassembly.c:82:72:    got restricted __be32 [usertype] id
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>

Applied, thanks Eric.
