From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] [v2] net/fsl_pq_mdio: add support for the Fman 1G
 MDIO controller
Date: Thu, 30 Aug 2012 13:31:16 -0400 (EDT)
Message-ID: <20120830.133116.1150456106601666639.davem@davemloft.net>
References: <1346263683-3664-1-git-send-email-timur@freescale.com>
	<1346263683-3664-7-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: timur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38121 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608Ab2H3RbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 13:31:18 -0400
In-Reply-To: <1346263683-3664-7-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@freescale.com>
Date: Wed, 29 Aug 2012 13:08:03 -0500

> The MDIO controller on the Frame Manager (Fman) is compatible with the
> QE and Gianfar MDIO controllers, but we don't care about the TBI because
> the Ethernet drivers (FMD) take care of programming it.
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>

Applied to net-next.
