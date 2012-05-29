From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skb: avoid unnecessary reallocations in __skb_cow
Date: Tue, 29 May 2012 17:23:16 -0400 (EDT)
Message-ID: <20120529.172316.1140196184351544154.davem@davemloft.net>
References: <1338298508-40376-1-git-send-email-nbd@openwrt.org>
	<1338298980.2840.32.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59994 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755877Ab2E2VXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 17:23:22 -0400
In-Reply-To: <1338298980.2840.32.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 29 May 2012 15:43:00 +0200

> On Tue, 2012-05-29 at 15:35 +0200, Felix Fietkau wrote:
> 
>> 
>> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
>> ---
>>  include/linux/skbuff.h |    2 --
>>  1 files changed, 0 insertions(+), 2 deletions(-)
>> 
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
