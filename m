From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH net-next,V2] net: macb: make magic-packet property generic
Date: Thu, 18 Feb 2016 08:37:20 -0600
Message-ID: <20160218143720.GP9654@rob-hp-laptop>
References: <1455664245-6842-1-git-send-email-sergio.prado@e-labworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	nicolas.ferre@atmel.com, davem@davemloft.net,
	gregory.clement@free-electrons.com, narmstrong@baylibre.com,
	michal.simek@xilinx.com, harini.katakam@xilinx.com,
	boris.brezillon@free-electrons.com, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sergio Prado <sergio.prado@e-labworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1455664245-6842-1-git-send-email-sergio.prado@e-labworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 16, 2016 at 09:10:45PM -0200, Sergio Prado wrote:
> As requested by Rob Herring on patch
> https://patchwork.ozlabs.org/patch/580862/.
> 
> This is a new property that it's still in net-next and has never been
> used in production, so we are not breaking anything with the
> incompatible binding change.
> 
> Signed-off-by: Sergio Prado <sergio.prado@e-labworks.com>
> ---
> Changes v1 -> v2: add changelog comment to clarify that the existing
> property has never been used in production.
> ---
>  Documentation/devicetree/bindings/net/macb.txt | 2 +-
>  drivers/net/ethernet/cadence/macb.c            | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)

Acked-by: Rob Herring <robh@kernel.org>
