From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] stmmac: dwmac-socfpga: make
 socfpga_dwmac_pm_ops static
Date: Mon, 09 May 2016 22:40:40 -0400 (EDT)
Message-ID: <20160509.224040.1459791490904008872.davem@davemloft.net>
References: <1462708043-8486-1-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
	dinguyen@opensource.altera.com
To: manabian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36228 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897AbcEJCkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 22:40:43 -0400
In-Reply-To: <1462708043-8486-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joachim Eastwood <manabian@gmail.com>
Date: Sun,  8 May 2016 13:47:23 +0200

> Fix the following sparse warning:
> drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c:274:1: warning:
>   symbol 'socfpga_dwmac_pm_ops' was not declared. Should it be static?
> 
> Signed-off-by: Joachim Eastwood <manabian@gmail.com>

Applied.
