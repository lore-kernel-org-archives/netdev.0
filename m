From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: NET_IPV4_ROUTE_GC_INTERVAL removal
Date: Mon, 03 Oct 2011 14:13:29 -0400 (EDT)
Message-ID: <20111003.141329.126723513891435653.davem@davemloft.net>
References: <1317381070-19564-1-git-send-email-vvs@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vvs@sw.ru
To: vvs@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56549 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932138Ab1JCSPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 14:15:12 -0400
In-Reply-To: <1317381070-19564-1-git-send-email-vvs@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasily Averin <vvs@parallels.com>
Date: Fri, 30 Sep 2011 15:11:10 +0400

> From: Vasily Averin <vvs@sw.ru>
> 
> removing obsoleted sysctl, 
> ip_rt_gc_interval variable no longer used since 2.6.38
> 
> Signed-off-by: Vasily Averin <vvs@sw.ru>

Applied, thanks.
