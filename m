From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net-next) v3] net: stmmac: fix warning from Sparse for
 socfpga
Date: Fri, 29 Aug 2014 20:49:44 -0700 (PDT)
Message-ID: <20140829.204944.664583582819173206.davem@davemloft.net>
References: <1409201986-3514-1-git-send-email-lftan@altera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	lftan.linux@gmail.com, peppe.cavallaro@st.com, vbridger@altera.com
To: lftan@altera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409201986-3514-1-git-send-email-lftan@altera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ley Foon Tan <lftan@altera.com>
Date: Thu, 28 Aug 2014 12:59:46 +0800

> Warning:
> drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c:122:41:
> sparse: cast removes address space of expression
> drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c:122:38:
> sparse: incorrect type in assignment (different address spaces)
> 
> Signed-off-by: Ley Foon Tan <lftan@altera.com>

Applied, thanks.
