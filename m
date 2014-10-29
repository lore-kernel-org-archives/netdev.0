From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/3] Add flow control support flags to
 gianfar's capabilities
Date: Wed, 29 Oct 2014 14:33:37 -0400 (EDT)
Message-ID: <20141029.143337.1175973358386727804.davem@davemloft.net>
References: <1414399364-22308-1-git-send-email-matei.pavaluca@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, claudiu.manoil@freescale.com
To: matei.pavaluca@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45282 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226AbaJ2Sdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 14:33:39 -0400
In-Reply-To: <1414399364-22308-1-git-send-email-matei.pavaluca@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matei Pavaluca <matei.pavaluca@freescale.com>
Date: Mon, 27 Oct 2014 10:42:42 +0200

> From: Pavaluca Matei-B46610 <matei.pavaluca@freescale.com>
> 
> The phy device supports 802.3x flow control, but the specific flags are not set
> in the phy initialisation code. Flow control flags need to be added to the
> supported capabilities of the phydev by the driver.
> 
> This is needed in order for ethtool to work ('ethtool -A' code checks for these
> flags)
> 
> Signed-off-by: Pavaluca Matei <matei.pavaluca@freescale.com>

Applied.
