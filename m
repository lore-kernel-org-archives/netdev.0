From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] ifb: support more features
Date: Mon, 09 May 2016 00:01:54 -0400 (EDT)
Message-ID: <20160509.000154.2249776807369776317.davem@davemloft.net>
References: <1462578076.13075.63.camel@edumazet-glaptop3.roam.corp.google.com>
	<1462583999.13075.67.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53952 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbcEIEB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 00:01:56 -0400
In-Reply-To: <1462583999.13075.67.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 May 2016 18:19:59 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When using ifb+netem on ingress on SIT/IPIP/GRE traffic,
> GRO packets are not properly processed.
> 
> Segmentation should not be forced, since ifb is already adding
> quite a performance hit.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
