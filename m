From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] ipip/ip6tnl: allow to switch netns during
 encap/decap
Date: Thu, 04 Jul 2013 14:56:21 -0700 (PDT)
Message-ID: <20130704.145621.2060744817757546493.davem@davemloft.net>
References: <20130627.223621.1852663736303796496.davem@davemloft.net>
	<1372863636-8866-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, bcrl@kvack.org,
	ravi.mlists@gmail.com, bhutchings@solarflare.com,
	eric.dumazet@gmail.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51087 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932805Ab3GDV4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 17:56:22 -0400
In-Reply-To: <1372863636-8866-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed,  3 Jul 2013 17:00:33 +0200

> 
> This patch is a follow up of the previous serie witch add this functionality
> for sit tunnels.
> 
> The goal is to add x-netns support for the module ipip and ip6_tunnel, ie the
> encapsulation addresses and the network device are not owned by the same
> namespace.
> 
> Note that the first patch is a fix of the previous serie.

The first patch, as it is a bug fix, is fine and is applied.

The rest will have to wait until the net-next tree opens again,
sorry.
