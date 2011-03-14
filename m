From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/6] net: sh_eth: remove the SH_TSU_ADDR
Date: Mon, 14 Mar 2011 14:10:50 -0700 (PDT)
Message-ID: <20110314.141050.59668181.davem@davemloft.net>
References: <4D75E1E6.10108@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35158
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757246Ab1CNVKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 17:10:12 -0400
In-Reply-To: <4D75E1E6.10108@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Date: Tue, 08 Mar 2011 16:59:34 +0900

> The defination is hardcoded in this driver for some CPUs. This patch
> modifies to get resource of TSU address from platform_device.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Applied.
