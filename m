From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [NET]: remove unnecessary #include
Date: Thu, 14 Aug 2008 04:28:27 -0400
Message-ID: <48A3ECAB.1080403@pobox.com>
References: <20080811125623.03D5.WEIYI.HUANG@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, jgarzik@redhat.com, netdev@vger.kernel.org
To: Huang Weiyi <weiyi.huang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41399 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753240AbYHNI2f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 04:28:35 -0400
In-Reply-To: <20080811125623.03D5.WEIYI.HUANG@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Huang Weiyi wrote:
> The drivers below do not use LINUX_VERSION_CODE nor KERNEL_VERSION.
>   drivers/net/acenic.c
>   drivers/net/bnx2x_link.c
>   drivers/net/bnx2x_main.c
>   drivers/net/cpmac.c
>   drivers/net/gianfar_sysfs.c
>   drivers/net/ipg.h
>   drivers/net/ppp_mppe.c
>   drivers/net/pppol2tp.c
>   drivers/net/r6040.c
>   drivers/net/sh_eth.c
>   drivers/net/sky2.c
>   drivers/net/tehuti.h
>   drivers/net/typhoon.c
> 
> This patch removes the said #include.
> 
> Signed-off-by: Huang Weiyi <hwy@cn.fujitsu.com>

applied


