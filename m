From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] net/phy: extra delay only for RGMII interfaces for
 IC+ IP 1001
Date: Tue, 18 Oct 2011 23:50:12 -0400 (EDT)
Message-ID: <20111018.235012.364231353381168528.davem@davemloft.net>
References: <1318318676-4493-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48432 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753470Ab1JSDuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 23:50:17 -0400
In-Reply-To: <1318318676-4493-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Tue, 11 Oct 2011 09:37:56 +0200

> The extra delay of 2ns to adjust RX clock phase is actually needed
> in RGMII mode. Tested on the HDK7108 (STx7108c2).
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied, thank you.
