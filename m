From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 2/3 (v2)] stmmac: add mixed burst for DMA
Date: Mon, 14 May 2012 18:54:03 -0400 (EDT)
Message-ID: <20120514.185403.424037378620121844.davem@davemloft.net>
References: <1336983523-4075-1-git-send-email-peppe.cavallaro@st.com>
	<1336983523-4075-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60351 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757964Ab2ENWyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 18:54:07 -0400
In-Reply-To: <1336983523-4075-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon, 14 May 2012 10:18:42 +0200

> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> 
> In mixed burst (MB) mode, the AHB master always initiates
> the bursts with fixed-size when the DMA requests transfers
> of size less than or equal to 16 beats.
> This patch adds the MB support and the flag that can be
> passed from the platform to select it.
> MB mode can also give some benefits in terms of performances
> on some platforms.
> 
> v2: fixed Coding Style
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
