From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ibm_newemac: Add support for GPCS, SGMII and M88E1112
 PHY
Date: Sat, 13 Sep 2008 15:41:23 -0400
Message-ID: <48CC1763.2050108@garzik.org>
References: <1220658926-14014-1-git-send-email-vgallardo@amcc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Victor Gallardo <vgallardo@amcc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36524 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752625AbYIMTl2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 15:41:28 -0400
In-Reply-To: <1220658926-14014-1-git-send-email-vgallardo@amcc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Victor Gallardo wrote:
> This patch adds GPCS, SGMII and M88E1112 PHY support
> for the AMCC PPC460GT/EX processors.
> 
> Signed-off-by: Victor Gallardo <vgallardo@amcc.com>
> ---
>  drivers/net/ibm_newemac/core.c |   40 +++++++++++++++----
>  drivers/net/ibm_newemac/core.h |    3 +
>  drivers/net/ibm_newemac/phy.c  |   84 ++++++++++++++++++++++++++++++++++++++++
>  drivers/net/ibm_newemac/phy.h  |    2 +
>  4 files changed, 120 insertions(+), 9 deletions(-)

ACK, please coordinate with the driver maintainer to get this merged


