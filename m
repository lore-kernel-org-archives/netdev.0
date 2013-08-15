From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] ipip/ip6tnl: allow to switch netns
 during encap/decap
Date: Thu, 15 Aug 2013 01:01:49 -0700 (PDT)
Message-ID: <20130815.010149.1288338225161487771.davem@davemloft.net>
References: <20130704.145621.2060744817757546493.davem@davemloft.net>
	<1376409072-6414-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, bcrl@kvack.org,
	ravi.mlists@gmail.com, bhutchings@solarflare.com,
	eric.dumazet@gmail.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37508 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754170Ab3HOIBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 04:01:51 -0400
In-Reply-To: <1376409072-6414-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 13 Aug 2013 17:51:08 +0200

> 
> This serie is a follow up of the previous serie witch adds this functionality
> for sit tunnels.
> 
> The goal is to add x-netns support for the module ipip and ip6_tunnel, ie the
> encapsulation addresses and the network device are not owned by the same
> namespace.
> 
> Note that the two first patches are cleanup.

Looks good, series applied, thanks.
