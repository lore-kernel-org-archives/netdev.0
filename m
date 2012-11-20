From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH net-next 1/1] sit: allow to configure 6rd
 tunnels via netlink
Date: Tue, 20 Nov 2012 13:45:15 -0500 (EST)
Message-ID: <20121120.134515.1372649705198223402.davem@davemloft.net>
References: <20121120.033405.490869980095149376.davem@davemloft.net>
	<1353400905-28335-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42527 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753423Ab2KTSpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 13:45:17 -0500
In-Reply-To: <1353400905-28335-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 20 Nov 2012 09:41:45 +0100

> This patch add the support of 6RD tunnels management via netlink.
> Note that netdev_state_change() is now called when 6RD parameters are updated.
> 
> 6RD parameters are updated only if there is at least one 6RD attribute.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks.
