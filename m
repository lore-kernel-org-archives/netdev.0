From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) 1/2] stmmac: fix GMAC syn ID
Date: Wed, 22 Aug 2012 19:14:46 -0700 (PDT)
Message-ID: <20120822.191446.1312199502434594592.davem@davemloft.net>
References: <1345631176-29494-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gianni.antoniazzi-ext@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60109 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753054Ab2HWCOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 22:14:49 -0400
In-Reply-To: <1345631176-29494-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Wed, 22 Aug 2012 12:26:15 +0200

> Erroneously the DWMAC_CORE_3_40 was set to 34 instead of 0x34.
> This can generate problems when run on old chips because
> the driver assumes that there are the extra 16 regs available
> for perfect filtering.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> Cc: Gianni Antoniazzi <gianni.antoniazzi-ext@st.com>

Applied.
