From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: gre: support SIT encapsulation
Date: Mon, 26 Oct 2015 22:01:40 -0700 (PDT)
Message-ID: <20151026.220140.437819068209052968.davem@davemloft.net>
References: <1445690864.22974.199.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35667 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185AbbJ0EpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 00:45:00 -0400
In-Reply-To: <1445690864.22974.199.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 24 Oct 2015 05:47:44 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> gre_gso_segment() chokes if SIT frames were aggregated by GRO engine.
> 
> Fixes: 61c1db7fae21e ("ipv6: sit: add GSO/TSO support")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
