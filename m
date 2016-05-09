From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: make sch_handle_ingress() drop monitor
 ready
Date: Sun, 08 May 2016 23:55:49 -0400 (EDT)
Message-ID: <20160508.235549.505902414432180706.davem@davemloft.net>
References: <1462575350.13075.60.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53911 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbcEIDzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 23:55:52 -0400
In-Reply-To: <1462575350.13075.60.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 May 2016 15:55:50 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> TC_ACT_STOLEN is used when ingress traffic is mirred/redirected
> to say ifb.
> 
> Packet is not dropped, but consumed.
> 
> Only TC_ACT_SHOT is a clear indication something went wrong.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>

Applied.
