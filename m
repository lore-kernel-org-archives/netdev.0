From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] stmmac: remove warning when compile as built-in
 (V2)
Date: Thu, 21 Jul 2011 15:30:28 -0700 (PDT)
Message-ID: <20110721.153028.286909021168010445.davem@davemloft.net>
References: <1311156324-23928-1-git-send-email-peppe.cavallaro@st.com>
	<1311156324-23928-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069Ab1GUWae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 18:30:34 -0400
In-Reply-To: <1311156324-23928-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Wed, 20 Jul 2011 12:05:22 +0200

> The patch removes the following serie of warnings
> when the driver is compiled as built-in:
> 
> drivers/net/stmmac/stmmac_main.c: In function stmmac_cmdline_opt:
> drivers/net/stmmac/stmmac_main.c:1855:12: warning: ignoring return
> value of kstrtoul, declared with attribute warn_unused_result
> [snip]
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
