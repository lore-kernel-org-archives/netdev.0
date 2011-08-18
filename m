From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: fix port mirror/redirect stats reporting
Date: Wed, 17 Aug 2011 20:10:50 -0700 (PDT)
Message-ID: <20110817.201050.523291202617562642.davem@davemloft.net>
References: <1313421940.1798.2.camel@mojatatu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jhs@mojatatu.com, hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38456 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754810Ab1HRDK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2011 23:10:58 -0400
In-Reply-To: <1313421940.1798.2.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Mon, 15 Aug 2011 11:25:40 -0400

> commit 6a51508a01671114c236602d071d4bff53422c60
> Author: Jamal Hadi Salim <jhs@mojatatu.com>
> Date:   Mon Aug 15 11:17:06 2011 -0400
> 
>     [PATCH] net_sched: fix port mirror/redirect stats reporting
>     
>     When a redirected or mirrored packet is dropped by the target
>     device we need to record statistics.
>     
>     Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied, thanks.
