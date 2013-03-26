From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 0/5] Tunneling: Tunnel restructuring.
Date: Tue, 26 Mar 2013 12:27:56 -0400 (EDT)
Message-ID: <20130326.122756.1279568367408031984.davem@davemloft.net>
References: <1364258969-3120-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40455 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933737Ab3CZQ16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:27:58 -0400
In-Reply-To: <1364258969-3120-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Mon, 25 Mar 2013 17:49:29 -0700

> Following patch series restructure GRE and IPIP tunneling code
> to make it modular. It adds ip_tunnel module which acts as
> generic tunneling layer which has common code.
> 
> These patches do not change any functionality.
> v3:v4:
>  - Fixed compilation error in ipv6.
>  - Few coding style fixes.
> v2-v3:
>  - Use GPL exports for all export symbols.
>  - Set default config NET_IP_TUNNEL to m.
> v1-v2:
>  - Dropped patch to convert gre_proto_lock to rtnl lock.

Series applied, thanks.
