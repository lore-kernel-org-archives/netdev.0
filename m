From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: add RCU annotation to sk_dst_cache field
Date: Wed, 23 Jan 2013 00:36:57 -0500 (EST)
Message-ID: <20130123.003657.2229339219402321614.davem@davemloft.net>
References: <1358917086.4235.12.camel@cr0>
	<1358917603.12374.713.camel@edumazet-glaptop>
	<1358919057.4235.17.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929Ab3AWFg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 00:36:58 -0500
In-Reply-To: <1358919057.4235.17.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed, 23 Jan 2013 13:30:57 +0800

> I expect most of them are from decnet, which is (partially) deprecated?

decnet is not deprecated, people use and test it, just fix the
warnings, implement your patch properly, and stop arguing.
