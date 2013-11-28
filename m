From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] net: sfc: remove unnecessary pci_set_drvdata()
Date: Thu, 28 Nov 2013 18:11:37 -0500 (EST)
Message-ID: <20131128.181137.2129415290144555685.davem@davemloft.net>
References: <000101cee97f$b2271ff0$16755fd0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	bhutchings@solarflare.com
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001Ab3K1XLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 18:11:41 -0500
In-Reply-To: <000101cee97f$b2271ff0$16755fd0$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Can you please resubmit these pci_set_drvdata() patches (the IRDA,
WAN, hippi, fiddi ones too) when I open the net-next tree back up?

Thank you.
