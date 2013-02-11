From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) 1/2] stmmac: fix macro used for debugging the
 xmit
Date: Sun, 10 Feb 2013 20:12:36 -0500 (EST)
Message-ID: <20130210.201236.1184389325028564572.davem@davemloft.net>
References: <1360219672-27980-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60519 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358Ab3BKBMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 20:12:37 -0500
In-Reply-To: <1360219672-27980-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu,  7 Feb 2013 07:47:51 +0100

> This patch fixes the name of the macro used for
> debugging the transmit process. I used STMMAC_TX_DEBUG
> instead of STMMAC_XMIT_DEBUG.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
