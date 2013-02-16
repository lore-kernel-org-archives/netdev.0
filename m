From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] v3 GRE: TCP segmentation offload
Date: Fri, 15 Feb 2013 20:53:57 -0500 (EST)
Message-ID: <20130215.205357.1130450552934768436.davem@davemloft.net>
References: <1360871081-1987-1-git-send-email-pshelar@nicira.com>
	<20130215.151824.1125629773152171791.davem@davemloft.net>
	<1360975955.19353.32.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org, edumazet@google.com,
	jesse@nicira.com, bhutchings@solarflare.com, mirqus@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47161 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074Ab3BPByC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 20:54:02 -0500
In-Reply-To: <1360975955.19353.32.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 15 Feb 2013 16:52:35 -0800

> There is this "tx-nocache-copy" issue : 

That scheme has so many system and device dependencies, but when
it does help it's nice to have.

Unfortunately I don't know the best way to proceed about that.
