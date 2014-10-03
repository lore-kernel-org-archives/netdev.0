From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: do not export skb_gro_receive()
Date: Fri, 03 Oct 2014 15:54:41 -0700 (PDT)
Message-ID: <20141003.155441.750268987095386445.davem@davemloft.net>
References: <1412260726.16704.99.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60506 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755541AbaJCWwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:52:35 -0400
In-Reply-To: <1412260726.16704.99.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Oct 2014 07:38:46 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> skb_gro_receive() is only called from tcp_gro_receive() which is
> not in a module.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
