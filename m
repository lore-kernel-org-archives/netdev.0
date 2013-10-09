From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] ipv6: make lookups simpler and faster
Date: Wed, 09 Oct 2013 00:07:50 -0400 (EDT)
Message-ID: <20131009.000750.1849276529051781060.davem@davemloft.net>
References: <1380840149.19002.256.camel@edumazet-glaptop.roam.corp.google.com>
	<20131008.232125.1605815898898029345.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34104 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462Ab3JIEHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 00:07:53 -0400
In-Reply-To: <20131008.232125.1605815898898029345.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric, I had to fix up l2tp_core.c to accomodate these changes due to
something that came in during the net --> net-next merge, please
double check my work.

Thanks.
