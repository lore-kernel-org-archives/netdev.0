From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: harden fnhe_hashfun()
Date: Fri, 05 Sep 2014 17:40:51 -0700 (PDT)
Message-ID: <20140905.174051.1401281945163111851.davem@davemloft.net>
References: <1409844091.26422.123.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58016 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725AbaIFAkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 20:40:52 -0400
In-Reply-To: <1409844091.26422.123.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 04 Sep 2014 08:21:31 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Lets make this hash function a bit secure, as ICMP attacks are still
> in the wild.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
