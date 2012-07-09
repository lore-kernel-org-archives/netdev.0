From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/macb: manage carrier state with call to
 netif_carrier_{on|off}()
Date: Mon, 09 Jul 2012 00:03:26 -0700 (PDT)
Message-ID: <20120709.000326.1862834306569616029.davem@davemloft.net>
References: <1341361835.2839.21.camel@bwh-desktop.uk.solarflarecom.com>
	<1341393253-6531-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	Arvid.Brodin@xdin.com, kuznet@ms2.inr.ac.ru, shemminger@vyatta.com,
	linux-arm-kernel@lists.infradead.org
To: nicolas.ferre@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53477 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165Ab2GIHD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 03:03:27 -0400
In-Reply-To: <1341393253-6531-1-git-send-email-nicolas.ferre@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Wed, 4 Jul 2012 11:14:13 +0200

> OFF carrier state is setup in probe() open() and suspend() functions.
> The carrier ON state is managed in macb_handle_link_change().
> 
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Applied to net-next, thanks.
