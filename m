From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) 2/2] stmmac: fix a typo in the macro used to
 mask the mmc irq
Date: Wed, 22 Aug 2012 19:14:53 -0700 (PDT)
Message-ID: <20120822.191453.141607422060635402.davem@davemloft.net>
References: <1345631176-29494-1-git-send-email-peppe.cavallaro@st.com>
	<1345631176-29494-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60114 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755435Ab2HWCO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 22:14:56 -0400
In-Reply-To: <1345631176-29494-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Wed, 22 Aug 2012 12:26:16 +0200

> This patch fixes the name of the macro used to mask the
> mmc interrupt: erroneously it was used: MMC_DEFAUL_MASK.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
