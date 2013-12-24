From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4 net-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Tue, 24 Dec 2013 00:31:25 -0500 (EST)
Message-ID: <20131224.003125.1848179270970861998.davem@davemloft.net>
References: <1387424650.19078.355.camel@edumazet-glaptop2.roam.corp.google.com>
	<52B3BAD1.30205@windriver.com>
	<52B8DF80.2010508@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, xiyou.wangcong@gmail.com,
	steffen.klassert@secunet.com, netdev@vger.kernel.org
To: fan.du@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33875 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711Ab3LXFba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 00:31:30 -0500
In-Reply-To: <52B8DF80.2010508@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>
Date: Tue, 24 Dec 2013 09:12:32 +0800

> I saw this patch is marked 'Not Applicable' in patchwork.

It means that it doesn't go in via my tree directly, it
"doesn't apply".

Instead, it goes into Steffen's IPSEC tree.
