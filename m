From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netem: fix build error on 32bit arches
Date: Thu, 01 Dec 2011 12:46:17 -0500 (EST)
Message-ID: <20111201.124617.1650707926728373968.davem@davemloft.net>
References: <cfd2e2c26063da002d8afe76991ff0c1@localhost>
	<1322730108.2335.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1322731934.2335.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36328 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755280Ab1LARqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 12:46:23 -0500
In-Reply-To: <1322731934.2335.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 01 Dec 2011 10:32:14 +0100

> ERROR: "__udivdi3" [net/sched/sch_netem.ko] undefined!
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
