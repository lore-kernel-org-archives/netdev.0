From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bgmac: add read of interrupt mask after disabling
 interrupts
Date: Thu, 14 Feb 2013 13:24:25 -0500 (EST)
Message-ID: <20130214.132425.1545950999539714554.davem@davemloft.net>
References: <BLU0-SMTP798071F8F18DD115610285AC0F0@phx.gbl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hauke@hauke-m.de, zajec5@gmail.com
To: nlhintz@hotmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58639 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758431Ab3BNSY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 13:24:29 -0500
In-Reply-To: <BLU0-SMTP798071F8F18DD115610285AC0F0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Hintz <nlhintz@hotmail.com>
Date: Wed, 13 Feb 2013 21:14:10 -0800

> The specs prescribe an immediate read of the interrupt mask after
> disabling interrupts.  This patch updates the driver to match the
> specs.
> 
> Signed-off-by: Nathan Hintz <nlhintz@hotmail.com>

Applied to net-next.

Please state clearly, in your Subject line, what tree your patch is
targetted at.  In this case "[PATCH net-next] " would have been
an appropriate subject prefix.
