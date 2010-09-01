From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warnings after merge of the net tree
Date: Tue, 31 Aug 2010 20:57:23 -0700 (PDT)
Message-ID: <20100831.205723.43021492.davem@davemloft.net>
References: <20100831115508.078eb2fa.sfr@canb.auug.org.au>
	<20100830.215641.71568585.davem@davemloft.net>
	<20100901112501.570e06a1.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, peppe.cavallaro@st.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100901112501.570e06a1.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 1 Sep 2010 11:25:01 +1000

> However, I missed one yesterday ...
> 
> drivers/net/stmmac/dwmac100_core.c: In function 'dwmac100_dump_mac_regs':
> drivers/net/stmmac/dwmac100_core.c:47: warning: cast from pointer to integer of different size

Thanks I'll take care of this.
