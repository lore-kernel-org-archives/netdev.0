From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2(net.git)] stmmac: fix for hw timestamp of GMAC3 unit
Date: Fri, 09 Jun 2017 12:39:58 -0400 (EDT)
Message-ID: <20170609.123958.1585982596323379101.davem@davemloft.net>
References: <trinity-8bed4ae0-8914-46c8-b515-dda572c13b88-1496957702157@3capp-webde-bs49>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mario_Molitor@web.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <trinity-8bed4ae0-8914-46c8-b515-dda572c13b88-1496957702157@3capp-webde-bs49>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Mario Molitor" <Mario_Molitor@web.de>
Date: Thu, 8 Jun 2017 23:35:02 +0200

> From d5c520880a5f6b470cb150b9aae67341089b9395 Mon Sep 17 00:00:00 2001
> From: Mario Molitor <mario_molitor@web.de>
> Date: Thu, 8 Jun 2017 23:03:09 +0200
> Subject: [PATCH 2/2] stmmac: fix for hw timestamp of GMAC3 unit
> 
> 1.) Bugfix of function stmmac_get_tx_hwtstamp.
>     Corrected the tx timestamp available check (same as 4.8 and older)
>     Change printout from info syslevel to debug.
> 
> 2.) Bugfix of function stmmac_get_rx_hwtstamp.
>     Corrected the rx timestamp available check (same as 4.8 and older)
>     Change printout from info syslevel to debug.
> 
> Fixes: ba1ffd74df74 ("stmmac: fix PTP support for GMAC4")
> Signed-off-by: Mario Molitor <mario_molitor@web.de>

Applied.
