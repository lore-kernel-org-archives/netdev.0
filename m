From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gianfar: Increase TX_TIMEOUT to 5HZ
Date: Tue, 27 Oct 2015 20:14:13 -0700 (PDT)
Message-ID: <20151027.201413.1759584308305258974.davem@davemloft.net>
References: <1445935663-15117-1-git-send-email-abhimanyu@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, claudiu.manoil@freescale.com,
	Priyanka.Jain@freescale.com
To: abhimanyu@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44743 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754858AbbJ1C5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 22:57:32 -0400
In-Reply-To: <1445935663-15117-1-git-send-email-abhimanyu@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Abhimanyu <abhimanyu@freescale.com>
Date: Tue, 27 Oct 2015 14:17:43 +0530

> Increased TX_TIMEOUT to 5HZ to accommodate worst case situation
> for traffic and CPU intensive use cases
> 
> Signed-off-by: Priyanka Jain <Priyanka.Jain@freescale.com>
> Signed-off-by: Abhimanyu <abhimanyu@freescale.com>

Applied, thanks.
