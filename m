From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: make sysctl_tcp_ecn namespace aware
Date: Sun, 06 Jan 2013 21:10:04 -0800 (PST)
Message-ID: <20130106.211004.1673336179828000831.davem@davemloft.net>
References: <1357435646.1678.5082.camel@edumazet-glaptop>
	<20130106021048.GA32202@order.stressinduktion.org>
	<1357438762.1678.5215.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38108 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030Ab3AGFKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 00:10:05 -0500
In-Reply-To: <1357438762.1678.5215.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 05 Jan 2013 18:19:22 -0800

> On Sun, 2013-01-06 at 03:10 +0100, Hannes Frederic Sowa wrote:
>> As per suggestion from Eric Dumazet this patch makes tcp_ecn sysctl
>> namespace aware.  The reason behind this patch is to ease the testing
>> of ecn problems on the internet and allows applications to tune their
>> own use of ecn.
>> 
>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: David Miller <davem@davemloft.net>
>> Cc: Stephen Hemminger <shemminger@vyatta.com>
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> ---
> 
> Seems good to me, thanks !
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
