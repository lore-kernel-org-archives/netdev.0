From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp_westwood: fix tcp_westwood_info()
Date: Thu, 30 Apr 2015 00:28:19 -0400 (EDT)
Message-ID: <20150430.002819.2177764333132481506.davem@davemloft.net>
References: <20150429.181252.2106091176943411796.davem@davemloft.net>
	<1430347239.3711.61.camel@edumazet-glaptop2.roam.corp.google.com>
	<1430349658.3711.71.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, ycheng@google.com,
	ncardwell@google.com, fengguang.wu@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53699 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbbD3E2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 00:28:23 -0400
In-Reply-To: <1430349658.3711.71.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 29 Apr 2015 16:20:58 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> I forgot to update tcp_westwood when changing get_info() behavior,
> this patch should fix this.
> 
> Fixes: 64f40ff5bbdb ("tcp: prepare CC get_info() access from getsockopt()")
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
