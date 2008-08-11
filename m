From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: remove unnecessary #include
Date: Mon, 11 Aug 2008 14:31:40 -0700 (PDT)
Message-ID: <20080811.143140.62797134.davem@davemloft.net>
References: <20080811125623.03D5.WEIYI.HUANG@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, jgarzik@pobox.com, jgarzik@redhat.com,
	netdev@vger.kernel.org
To: weiyi.huang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57841
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751960AbYHKVbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 17:31:39 -0400
In-Reply-To: <20080811125623.03D5.WEIYI.HUANG@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huang Weiyi <weiyi.huang@gmail.com>
Date: Mon, 11 Aug 2008 12:56:44 +0800

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

Acked-by: David S. Miller <davem@davemloft.net>
