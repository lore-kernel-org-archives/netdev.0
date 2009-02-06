From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: ck804 and mcp55 doesn't need timerirq
Date: Fri, 06 Feb 2009 01:32:20 -0800 (PST)
Message-ID: <20090206.013220.250415322.davem@davemloft.net>
References: <498BC3A8.9040203@kernel.org>
	<498BC43D.6020704@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, mingo@elte.hu, akpm@linux-foundation.org,
	aabdulla@nvidia.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: yinghai@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59574
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754422AbZBFJcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 04:32:25 -0500
In-Reply-To: <498BC43D.6020704@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yinghai Lu <yinghai@kernel.org>
Date: Thu, 05 Feb 2009 21:01:49 -0800

> 
> Impact: cleanup
> 
> so get less irq.
> 
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>

Applied to net-next-2.6
