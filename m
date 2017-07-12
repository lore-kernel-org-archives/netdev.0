From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: revert "support future possible different
 internal phy mode"
Date: Wed, 12 Jul 2017 14:42:32 -0700 (PDT)
Message-ID: <20170712.144232.1239782285136293791.davem@davemloft.net>
References: <20170712073234.9809-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170712073234.9809-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Wed, 12 Jul 2017 09:32:34 +0200

> Since internal phy-mode is reserved for non-xMII protocol we cannot use
> it with dwmac-sun8i.
> Furthermore, all DT patchs which comes with this patch were cleaned, so
> the current state is broken.
> This reverts commit 1c2fa5f84683 ("net: stmmac: support future possible different internal phy mode")
> 
> Fixes: 1c2fa5f84683 ("net: stmmac: support future possible different internal phy mode")
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Applied, thanks.
