From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipv4/route: arg delay is useless in
 rt_cache_flush()
Date: Fri, 07 Sep 2012 14:44:29 -0400 (EDT)
Message-ID: <20120907.144429.1841200052046360061.davem@davemloft.net>
References: <1347013794.2484.488.camel@edumazet-glaptop>
	<1347014729-28461-1-git-send-email-nicolas.dichtel@6wind.com>
	<1347031479.2484.799.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40255 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755742Ab2IGSoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 14:44:30 -0400
In-Reply-To: <1347031479.2484.799.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 07 Sep 2012 17:24:39 +0200

> On Fri, 2012-09-07 at 12:45 +0200, Nicolas Dichtel wrote:
>> Since route cache deletion (89aef8921bfbac22f), delay is no
>> more used. Remove it.
>> 
>> v2: remove ctl in ipv4_sysctl_rtcache_flush()
>> 
> 
> Ideally, this v2:....: should be after the --- marker

I took care of this.

>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
...
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
