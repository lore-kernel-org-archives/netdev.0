From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 3/4] stmmac: prevent dma init stuck in case of
 failures.
Date: Fri, 17 Sep 2010 16:13:30 -0700 (PDT)
Message-ID: <20100917.161330.172619222.davem@davemloft.net>
References: <1284729822-29176-1-git-send-email-peppe.cavallaro@st.com>
	<1284729822-29176-2-git-send-email-peppe.cavallaro@st.com>
	<1284729822-29176-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54660
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752160Ab0IQXNL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 19:13:11 -0400
In-Reply-To: <1284729822-29176-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Fri, 17 Sep 2010 15:23:41 +0200

> Add a limit when perform the DMA reset procedure
> so, in case of problems (i.e. PHY reset failed) the
> Kernel won't hang on the stmmac DMA initialisation
> blocking the Kernels execution.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
