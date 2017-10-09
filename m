From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: stmmac: Clean up dead code
Date: Sun, 08 Oct 2017 21:19:27 -0700 (PDT)
Message-ID: <20171008.211927.1175489723468947303.davem@davemloft.net>
References: <1507490029-26406-1-git-send-email-chris.gekas@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: chris.gekas@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507490029-26406-1-git-send-email-chris.gekas@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christos Gkekas <chris.gekas@gmail.com>
Date: Sun,  8 Oct 2017 20:13:49 +0100

> Many macros in dwmac-ipq806x are unused and should be removed.
> Moreover gmac->id is an unsigned variable and therefore checking
> whether it is less than zero is redundant.
> 
> Signed-off-by: Christos Gkekas <chris.gekas@gmail.com>

Applied.
