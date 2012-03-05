From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] stmmac: configure burst related GMAC DMA parameters
Date: Sun, 04 Mar 2012 20:52:12 -0500 (EST)
Message-ID: <20120304.205212.433059905942216884.davem@davemloft.net>
References: <1330692928-30330-4-git-send-email-deepak.sikri@st.com>
	<1330692928-30330-5-git-send-email-deepak.sikri@st.com>
	<1330692928-30330-6-git-send-email-deepak.sikri@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, spear-devel@list.st.com,
	netdev@vger.kernel.org, shiraz.hashim@st.com, vikas.manocha@st.com
To: deepak.sikri@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47615 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755314Ab2CEBwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 20:52:21 -0500
In-Reply-To: <1330692928-30330-6-git-send-email-deepak.sikri@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Deepak Sikri <deepak.sikri@st.com>
Date: Fri, 2 Mar 2012 18:25:27 +0530

>  	writel(value, ioaddr + DMA_BUS_MODE);
> +	/*
> +	 * We need to program DMA_AXI_BUS_MODE for supported bursts in
> +	 * case DMA_BUS_MODE_FB mode is selected

Please fix comment formatting.
