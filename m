From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Advertise tunnel parameters via netlink
Date: Fri, 09 Nov 2012 19:36:39 -0500 (EST)
Message-ID: <20121109.193639.1214893184051042519.davem@davemloft.net>
References: <1352467239.19779.564.camel@edumazet-glaptop>
	<1352477401-19044-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39589 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581Ab2KJAgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 19:36:43 -0500
In-Reply-To: <1352477401-19044-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri,  9 Nov 2012 17:09:58 +0100

> The goal of this serie is to advertise tunnel parameters via netlink.
> 
> It is usefull for daemons that monitor link event to have the full parameters
> of these interfaces.
> 
> The patch against iproute2 will be sent once the patches are included and
> net-next merged. I can send it on demand.
> 
> v2: remove last patch of the serie, which was a bug fix.
>     enhance commit log.
> 
> Comments are welcome.

Really nice, all applied, thanks Nicolas.
