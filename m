From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] sfc: handle nonlinear SKBs in efx_filter_rfs()
Date: Thu, 26 May 2016 12:47:00 -0700 (PDT)
Message-ID: <20160526.124700.1694673077217909159.davem@davemloft.net>
References: <57471D92.2000708@solarflare.com>
	<57471DF5.8010901@solarflare.com>
	<1464281796.5939.96.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ecree@solarflare.com, linux-net-drivers@solarflare.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53912 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754903AbcEZTrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 15:47:01 -0400
In-Reply-To: <1464281796.5939.96.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 26 May 2016 09:56:36 -0700

> I truly believe that every time a driver has a private flow dissector,
> it always have at least one bug.

+1
