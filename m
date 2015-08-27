From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/6] rocker: make master change handling
 nicer
Date: Thu, 27 Aug 2015 16:28:55 -0700 (PDT)
Message-ID: <20150827.162855.1299418051364430498.davem@davemloft.net>
References: <1440660683-20086-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, simon.horman@netronome.com, f.fainelli@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48203 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753105AbbH0X24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 19:28:56 -0400
In-Reply-To: <1440660683-20086-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 27 Aug 2015 09:31:17 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Jiri Pirko (6):
>   net: introduce change upper device notifier change info
>   net: add netif_is_bridge_master helper
>   net: add netif_is_ovs_master helper with IFF_OPENVSWITCH private flag
>   net: kill long time unused bonding private flags
>   rocker: use new helper to figure out master kind
>   rocker: use change upper info

Series applied, thanks Jiri.
