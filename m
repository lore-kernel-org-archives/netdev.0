From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IrDA] irda-usb.c: STIR421x cleanups
Date: Sun, 11 Jun 2006 20:56:30 -0700 (PDT)
Message-ID: <20060611.205630.98748895.davem@davemloft.net>
References: <20060612061235.GB3736@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	nfedchik@atlantic-link.com.ua
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:32481
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751254AbWFLD4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jun 2006 23:56:24 -0400
To: samuel@sortiz.org
In-Reply-To: <20060612061235.GB3736@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel@sortiz.org>
Date: Mon, 12 Jun 2006 09:12:35 +0300

> This patch is for the net-2.6.18 tree.
> It cleans the STIR421x part of the irda-usb code. We also no longer try to
> load all existing firmwares but only the matching one (according to the USB
> id we get from the dongle).
> 
> Signed-off-by: Nick Fedchik <nfedchik@atlantic-link.com.ua>
> Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Applied, thanks a lot.
