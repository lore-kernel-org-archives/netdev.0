From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) 0/3 (v3)] stmmac fixes for net.git
Date: Wed, 06 Jun 2012 09:35:17 -0700 (PDT)
Message-ID: <20120606.093517.927544184133475085.davem@davemloft.net>
References: <1338873777-5374-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37133 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754849Ab2FFQfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 12:35:17 -0400
In-Reply-To: <1338873777-5374-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Tue,  5 Jun 2012 07:22:54 +0200

> These patches fix a problem in the driver when built as dynamic
> module and fix the driver's documentation.
> 
> v2: this patchset has the same patches I had sent before but
>     I removed a patch that did a cleanup (now moved for net-next).
> 
> v3: removed wrong reviewed-by from this patch:
>     "stmmac: fix driver Kconfig when built as module"
> 
> Giuseppe Cavallaro (3):
>   stmmac: fix driver's doc when run kernel-doc script
>   stmmac: update driver's doc
>   stmmac: fix driver Kconfig when built as module

All applied, thanks.
