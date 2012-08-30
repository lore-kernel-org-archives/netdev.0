From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] net/fsl_pq_mdio: merge some functions together
Date: Thu, 30 Aug 2012 13:30:37 -0400 (EDT)
Message-ID: <20120830.133037.1073189164474742420.davem@davemloft.net>
References: <1346263683-3664-1-git-send-email-timur@freescale.com>
	<1346263683-3664-3-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: timur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38099 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366Ab2H3Raj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 13:30:39 -0400
In-Reply-To: <1346263683-3664-3-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@freescale.com>
Date: Wed, 29 Aug 2012 13:07:59 -0500

> A few small functions were called only by other functions in the same
> file, so merge them together.  One function, for example, was calculating
> the device address even though the caller was doing the same thing.
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>

Applied to net-next.
