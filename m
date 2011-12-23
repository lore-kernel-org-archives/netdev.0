From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] stmmac: fix missing module license in the main.
Date: Fri, 23 Dec 2011 14:21:29 -0500 (EST)
Message-ID: <20111223.142129.655029415186686278.davem@davemloft.net>
References: <4EF3DB45.30401@xenotime.net>
	<1324636267-25533-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46176 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757647Ab1LWTVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 14:21:37 -0500
In-Reply-To: <1324636267-25533-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Fri, 23 Dec 2011 11:31:07 +0100

> This patch fixes the following warning raised
> when compile:
> 
> WARNING: modpost: missing MODULE_LICENSE()
> in drivers/net/ethernet/stmicro/stmmac/stmmac.o
> 
> Reported-by: Randy Dunlap <rdunlap@xenotime.net>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
