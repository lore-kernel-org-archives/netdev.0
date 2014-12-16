From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] Implementation of RFC 4898 Extended TCP
 Statistics (Web10G)
Date: Tue, 16 Dec 2014 17:44:07 -0500 (EST)
Message-ID: <20141216.174407.693047700796165794.davem@davemloft.net>
References: <20141216.151823.2276708539799601894.davem@davemloft.net>
	<54909DD5.5070202@psc.edu>
	<1418769212.9773.65.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rapier@psc.edu, alexei.starovoitov@gmail.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960AbaLPWoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 17:44:10 -0500
In-Reply-To: <1418769212.9773.65.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 16 Dec 2014 14:33:32 -0800

> There is very little chance web10g ~3000 lines of code are added into
> linux TCP stack, by people who did not submit netdev changes in last
> years.

+1

> At Google, we tried the web10g route, but reverted it (today !) in favor
> of tcp_info extensions (ss command from iproute2 can also grab/display
> these), after too many bugs being filled.

+1
