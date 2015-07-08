From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ifb: add multiqueue operation
Date: Wed, 08 Jul 2015 16:00:31 -0700 (PDT)
Message-ID: <20150708.160031.2291130777687277659.davem@davemloft.net>
References: <1436213128.4571.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@plumgrid.com, jhs@mojatatu.com,
	john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38174 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbbGHXAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 19:00:32 -0400
In-Reply-To: <1436213128.4571.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 06 Jul 2015 22:05:28 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Add multiqueue capabilities to ifb netdevice.
> 
> This removes last bottleneck for ingress when mq qdisc can be used
> to shard load from multiple RX queues on physical device.
> 
> Tested:
...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
