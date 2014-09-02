From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) 2/2] stmmac: only remove RXCSUM feature if no
 rx coe is available
Date: Mon, 01 Sep 2014 21:52:16 -0700 (PDT)
Message-ID: <20140901.215216.1403511391598831789.davem@davemloft.net>
References: <1409555873-5478-1-git-send-email-peppe.cavallaro@st.com>
	<1409555873-5478-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47438 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910AbaIBEwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 00:52:17 -0400
In-Reply-To: <1409555873-5478-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Mon, 1 Sep 2014 09:17:53 +0200

> In case of the HW is not able to do the receive checksum offloading
> the only feature to remove is NETIF_F_RXCSUM.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
