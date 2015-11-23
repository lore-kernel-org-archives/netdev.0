From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [V2] net: fsl: expands dependencies of
 NET_VENDOR_FREESCALE
Date: Mon, 23 Nov 2015 12:12:57 -0500 (EST)
Message-ID: <20151123.121257.781288069885534291.davem@davemloft.net>
References: <1447991648-25424-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Shaohui.Xie@freescale.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbbKWRM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 12:12:59 -0500
In-Reply-To: <1447991648-25424-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <shh.xie@gmail.com>
Date: Fri, 20 Nov 2015 11:54:08 +0800

> From: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> Freescale hosts some ARMv8 based SoCs, and a generic convention
> ARCH_LAYERSCAPE is used to cover such SoCs. Adding ARCH_LAYERSCAPE
> to dependencies of NET_VENDOR_FREESCALE to support networking on those
> SoCs.
> 
> The ARCH_LAYERSCAPE is introduced by:
> commit: 53a5fde05 arm64: Use generic Layerscape SoC family naming
> 
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
> ---
> changes in v2:
> 1. revises commit message to add commit which introduces ARCH_LAYERSCAPE.

Applied.
