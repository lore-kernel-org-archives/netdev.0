From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 08/13] Use menuconfig objects II - netdev (general+100mbit)
Date: Fri, 11 May 2007 16:57:52 -0400
Message-ID: <4644D8D0.3080602@garzik.org>
References: <200705110552.l4B5quBQ007813@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jengelh@linux01.gwdg.de, jengelh@gmx.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42350 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759313AbXEKU5y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 16:57:54 -0400
In-Reply-To: <200705110552.l4B5quBQ007813@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Jan Engelhardt <jengelh@linux01.gwdg.de>
> 
> CONFIG_NETDEVICES, CONFIG_NET_ETHERNET:
> Change Kconfig objects from "menu, config" into "menuconfig" so
> that the user can disable the whole feature without having to
> enter the menu first.
> 
> CONFIG_SMC9194:
> Move it so that it appears correctly in menuconfig.
> 
> Signed-off-by: Jan Engelhardt <jengelh@gmx.de>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/Kconfig         |  167 ++++++++++++++++------------------
>  drivers/net/arm/Kconfig     |   12 +-
>  drivers/net/fec_8xx/Kconfig |    2 
>  drivers/net/fs_enet/Kconfig |    2 
>  drivers/net/tulip/Kconfig   |   27 ++---
>  5 files changed, 102 insertions(+), 108 deletions(-)

ACK, but failed to apply


