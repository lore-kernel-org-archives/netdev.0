From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net_sched: sch_mqprio: dont leak kernel
 memory
Date: Wed, 26 Jan 2011 13:15:45 -0800 (PST)
Message-ID: <20110126.131545.112593169.davem@davemloft.net>
References: <1296062517.2899.86.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55016
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752932Ab1AZVPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 16:15:10 -0500
In-Reply-To: <1296062517.2899.86.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 26 Jan 2011 18:21:57 +0100

> mqprio_dump() should make sure all fields of struct tc_mqprio_qopt are
> initialized.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: John Fastabend <john.r.fastabend@intel.com>

Applied, thanks Eric.
