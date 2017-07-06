From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH 6/6] net: stmmac: revert "support future possible
 different internal phy mode"
Date: Thu, 6 Jul 2017 10:51:47 +0200
Message-ID: <20170706085147.GA15728@Red>
References: <20170702123159.6939-1-clabbe.montjoie@gmail.com>
 <20170702123159.6939-7-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-sunxi@googlegroups.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170702123159.6939-7-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 02, 2017 at 02:31:59PM +0200, Corentin Labbe wrote:
> Since internal phy-mode is reserved for non-xMII protocol we cannot use
> it with dwmac-sun8i
> This reverts commit 1c2fa5f84683 ("net: stmmac: support future possible different internal phy mode")
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---

Hello

This patch was left not applied but all other patch from this serie was.
Could you apply it, or perhaps you prefer I resend it with some "Fixes:"

Regards
Corentin Labbe
