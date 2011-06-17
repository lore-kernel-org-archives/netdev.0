From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio-net: per cpu 64 bit stats (v2)
Date: Fri, 17 Jun 2011 15:18:21 -0400 (EDT)
Message-ID: <20110617.151821.1341973645484302135.davem@davemloft.net>
References: <20110615114337.09fe62f6@s6510.ftrdhcpuser.net>
	<1308153538.3128.3.camel@edumazet-laptop>
	<20110615123629.6efae8aa@s6510.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39506 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932083Ab1FQTSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 15:18:34 -0400
In-Reply-To: <20110615123629.6efae8aa@s6510.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 15 Jun 2011 12:36:29 -0400

> Use per-cpu variables to maintain 64 bit statistics.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

I'll apply this, thanks.
