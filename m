From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git)] stmmac: platform: fix FIXED_PHY support.
Date: Tue, 14 Oct 2014 16:41:11 -0400 (EDT)
Message-ID: <20141014.164111.1512286766983174637.davem@davemloft.net>
References: <1413267114-24043-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44497 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753413AbaJNUlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 16:41:14 -0400
In-Reply-To: <1413267114-24043-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Tue, 14 Oct 2014 08:11:54 +0200

> On several STi platforms: e.g. stihxxx-b2120 an Ethernet switch is
> embedded and connected to the stmmac via RGMII mode. So this is managed
> by using the FIXED_PHY. In that case, the support in the platform needs
> to be fixed to allow the stmmac to dialog with the switch via fixed-link
> by using phy_bus_name property.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
