From: David Miller <davem@davemloft.net>
Subject: Re: low latency/busy poll feedback and bugs
Date: Wed, 07 Aug 2013 16:41:12 -0700 (PDT)
Message-ID: <20130807.164112.726899551465300402.davem@davemloft.net>
References: <52013F9A.9020005@linux.intel.com>
	<1375905901.27403.22.camel@deadeye.wl.decadent.org.uk>
	<1375907005.4004.47.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, eliezer.tamir@linux.intel.com,
	sbohrer@rgmadvisors.com, amirv@mellanox.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51413 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932633Ab3HGXf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 19:35:57 -0400
In-Reply-To: <1375907005.4004.47.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 07 Aug 2013 13:23:25 -0700

> On Wed, 2013-08-07 at 22:05 +0200, Ben Hutchings wrote:
> 
>> It seems like sk_mark_napi_id() should only be called on connected
>> sockets for now.
> 
> I concur.

Me too.
