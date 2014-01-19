From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: be friend with drop monitor
Date: Sat, 18 Jan 2014 23:08:36 -0800 (PST)
Message-ID: <20140118.230836.17636120756060889.davem@davemloft.net>
References: <1390098469.27806.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55221 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbaASHIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 02:08:36 -0500
In-Reply-To: <1390098469.27806.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 18 Jan 2014 18:27:49 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Replace some dev_kfree_skb() with kfree_skb() calls when
> we drop one skb, this might help bug tracking.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
