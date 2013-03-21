From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] sh_eth: probe/remove code cleanup/improvement
Date: Thu, 21 Mar 2013 17:21:47 -0400 (EDT)
Message-ID: <20130321.172147.102166480926323215.davem@davemloft.net>
References: <201303212336.16714.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47208 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491Ab3CUVVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 17:21:49 -0400
In-Reply-To: <201303212336.16714.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Thu, 21 Mar 2013 23:36:16 +0300

> Hello.
> 
>    Here is the series of 3 patches doing some cleanup and improvements to the
> driver's probe/remove code paths.
> 
> [1/3] sh_eth: use PIR_* bits
> [2/3] sh_eth: kill unneeded typecast in sh_eth_drv_probe()
> [3/3] sh_eth: use managed device API
> 
>    All patches are against the recent David Miller's net-next.git to which he
> has just helpfully merged my 2 recent fixes which are the base of the cleanups.

All applied, thanks.
