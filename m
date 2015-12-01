From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net-next.git)] stmmac: support Reg_9 to get HW level
 information
Date: Tue, 01 Dec 2015 16:06:24 -0500 (EST)
Message-ID: <20151201.160624.1203160297565712328.davem@davemloft.net>
References: <1448879590-3447-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57222 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754266AbbLAVG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 16:06:26 -0500
In-Reply-To: <1448879590-3447-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Mon, 30 Nov 2015 11:33:10 +0100

> For GMAC newer than 3.40a there is a new register (Reg_9) that provides the
> status of all modules of the transmit and receive paths and FIFO status.
> These can be exposed via ethtool.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
