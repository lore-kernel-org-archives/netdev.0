From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: shrink rt_cache_stat
Date: Thu, 17 Oct 2013 16:11:24 -0400 (EDT)
Message-ID: <20131017.161124.1563030317229518748.davem@davemloft.net>
References: <1381916944.2045.124.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46847 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758669Ab3JQUL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 16:11:26 -0400
In-Reply-To: <1381916944.2045.124.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Oct 2013 02:49:04 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Half of the rt_cache_stat fields are no longer used after IP
> route cache removal, lets shrink this per cpu area.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good, applied, thanks Eric.
