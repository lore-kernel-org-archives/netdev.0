From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] initialize fragment hash secrets with
 net_get_random_once
Date: Wed, 23 Oct 2013 17:02:44 -0400 (EDT)
Message-ID: <20131023.170244.1860098541779927169.davem@davemloft.net>
References: <1382519217-750-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41059 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754034Ab3JWVCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 17:02:46 -0400
In-Reply-To: <1382519217-750-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 23 Oct 2013 11:06:54 +0200

> This series switches the inet_frag.rnd hash initialization to
> net_get_random_once.
> 
> Included patches:
>  ipv4: initialize ip4_frags hash secret as late
>  ipv6: split inet6_hash_frag for netfilter and
>  inet: remove old fragmentation hash initializing

Looks good, series applied, thanks Hannes.
