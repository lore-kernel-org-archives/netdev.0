From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: don't clear nic_poll_irq too early
Date: Fri, 06 Feb 2009 01:31:28 -0800 (PST)
Message-ID: <20090206.013128.109083992.davem@davemloft.net>
References: <498BC3A8.9040203@kernel.org>
	<498BC3EE.3070209@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, mingo@elte.hu, akpm@linux-foundation.org,
	aabdulla@nvidia.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: yinghai@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59559
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754583AbZBFJbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 04:31:32 -0500
In-Reply-To: <498BC3EE.3070209@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yinghai Lu <yinghai@kernel.org>
Date: Thu, 05 Feb 2009 21:00:30 -0800

> 
> Impact: fix bug
> 
> for msix, we still need that flag to enable irq respectively
> 
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>

Applied to net-next-2.6
