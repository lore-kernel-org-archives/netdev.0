From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] nf_bridge: remove holes in struct
 nf_bridge_info
Date: Thu, 19 Apr 2012 15:19:11 -0400 (EDT)
Message-ID: <20120419.151911.1950614399106721567.davem@davemloft.net>
References: <1334827165.2395.63.camel@edumazet-glaptop>
	<20120419075246.0df140e9@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51562 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756398Ab2DSTTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 15:19:18 -0400
In-Reply-To: <20120419075246.0df140e9@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 19 Apr 2012 07:52:46 -0700

> On Thu, 19 Apr 2012 11:19:25 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> Put use & mask on same location to avoid two holes on 64bit arches
>> 
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
