From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] pkt_sched: fq: warn users using defrate
Date: Fri, 15 Nov 2013 21:06:33 -0500 (EST)
Message-ID: <20131115.210633.326047777015636759.davem@davemloft.net>
References: <1384534646.28716.75.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maze@google.com, willemb@google.com,
	ycheng@google.com, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32835 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068Ab3KPCGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 21:06:35 -0500
In-Reply-To: <1384534646.28716.75.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 15 Nov 2013 08:57:26 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 7eec4174ff29 ("pkt_sched: fq: fix non TCP flows pacing")
> obsoleted TCA_FQ_FLOW_DEFAULT_RATE without notice for the users.
> 
> Suggested by David Miller
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
