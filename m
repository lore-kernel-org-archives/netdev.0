From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/fsl: Make xgmac_mdio read error message useful
Date: Wed, 11 Jun 2014 15:59:16 -0700 (PDT)
Message-ID: <20140611.155916.1716311056474580307.davem@davemloft.net>
References: <1402512100-16735-1-git-send-email-Shruti@Freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Shruti@Freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47835 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377AbaFKW7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 18:59:16 -0400
In-Reply-To: <1402512100-16735-1-git-send-email-Shruti@Freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shruti Kanetkar <Shruti@Freescale.com>
Date: Wed, 11 Jun 2014 13:41:40 -0500

> Print the device address, the register number and the PHY ID for
> which the MDIO read operation failed
> 
> Signed-off-by: Shruti Kanetkar <Shruti@Freescale.com>

Applied.
