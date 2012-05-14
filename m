From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/3 (v2)] stmmac: extend mac addr reg and fix
 perfect filering
Date: Mon, 14 May 2012 18:53:53 -0400 (EDT)
Message-ID: <20120514.185353.847773450427065123.davem@davemloft.net>
References: <1336983523-4075-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gianni.antoniazzi-ext@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60344 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757964Ab2ENWx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 18:53:59 -0400
In-Reply-To: <1336983523-4075-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon, 14 May 2012 10:18:41 +0200

> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> 
> This patch is to extend the number of MAC address registers
> for 16 to 32. In fact, other new 16 registers are available in new
> chips and this can help on perfect filter mode for unicast.
> 
> This patch also fixes the perfect filtering mode by setting the
> bit 31 in the MAC address registers.
> 
> v2: fixed Coding Style.
> 
> Signed-off-by: Gianni Antoniazzi <gianni.antoniazzi-ext@st.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
