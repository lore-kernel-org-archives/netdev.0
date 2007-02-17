From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.21] phylib: Add support for Marvell 88e1111S and 88e1145
Date: Sat, 17 Feb 2007 15:17:19 -0500
Message-ID: <45D762CF.9060103@garzik.org>
References: <Pine.LNX.4.61.0702091808330.9158@ld0175-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47632 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956AbXBQURV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 15:17:21 -0500
In-Reply-To: <Pine.LNX.4.61.0702091808330.9158@ld0175-tx32.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Fleming wrote:
>>From Andy Fleming <afleming@freescale.com>
> 
> Changes include:
> * New support for 88e1145
> * New support for 88e111s
> * Fixing 88e1101 driver to not match non-88e1101 PHYs
> * Increases in feature support across Marvell PHY product line
> * Fixes a bunch of whitespace issues found by Lindent
> 
> Signed-off-by: Andrew Fleming <afleming@freescale.com>
> ---
> This patch seems to have gotten lost.  It still applies cleanly, so I'm 
> resubmitting it for 2.6.21.
> 
>  drivers/net/phy/marvell.c |  156 ++++++++++++++++++++++++++++++++++++++++++---
>  1 files changed, 144 insertions(+), 12 deletions(-)

applied


