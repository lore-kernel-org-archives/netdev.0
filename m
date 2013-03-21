From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] gianfar: Remove superfluous
 kernel_dropped local counter
Date: Thu, 21 Mar 2013 12:02:16 -0400 (EDT)
Message-ID: <20130321.120216.316723747814559628.davem@davemloft.net>
References: <1363871535-29612-1-git-send-email-claudiu.manoil@freescale.com>
	<1363871535-29612-3-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43723 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756408Ab3CUQCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 12:02:17 -0400
In-Reply-To: <1363871535-29612-3-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Thu, 21 Mar 2013 15:12:15 +0200

> The GRO_DROP return code is handled by the core network layer.
> The current kernel approach is to factorize this kind of statistics into
> the upper layers, instead of having all the drivers maintaining them.
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied.
