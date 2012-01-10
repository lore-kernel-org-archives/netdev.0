From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: Fix compilation error in mmc_core.c
Date: Tue, 10 Jan 2012 14:57:44 -0800 (PST)
Message-ID: <20120110.145744.2126202834928001174.davem@davemloft.net>
References: <1326196060-10283-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com
To: sr@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933329Ab2AJW5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 17:57:51 -0500
In-Reply-To: <1326196060-10283-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Roese <sr@denx.de>
Date: Tue, 10 Jan 2012 12:47:40 +0100

> Fix this error:
> 
>   CC      drivers/net/ethernet/stmicro/stmmac/mmc_core.o
> drivers/net/ethernet/stmicro/stmmac/mmc_core.c: In function 'dwmac_mmc_ctrl':
> drivers/net/ethernet/stmicro/stmmac/mmc_core.c:143:2: error: implicit
>   declaration of function 'pr_debug' [-Werror=implicit-function-declaration]
> 
> Signed-off-by: Stefan Roese <sr@denx.de>
> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
