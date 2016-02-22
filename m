From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH can-next 1/2] CAN: rcar: add gen[12] fallback
 compatibility strings
Date: Sun, 21 Feb 2016 21:37:20 -0600
Message-ID: <20160222033720.GA27711@rob-hp-laptop>
References: <1456107350-12100-1-git-send-email-horms+renesas@verge.net.au>
 <1456107350-12100-2-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Magnus Damm <magnus.damm@gmail.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	devicetree@vger.kernel.org
To: Simon Horman <horms+renesas@verge.net.au>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1456107350-12100-2-git-send-email-horms+renesas@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 22, 2016 at 11:15:49AM +0900, Simon Horman wrote:
> Add fallback compatibility string for R-Car Gen 1 and Gen2 families.
> This is in keeping with the fallback scheme being adopted wherever
> appropriate for drivers for Renesas SoCs.
> 
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> ---
>  Documentation/devicetree/bindings/net/can/rcar_can.txt | 4 +++-
>  drivers/net/can/rcar_can.c                             | 2 ++
>  2 files changed, 5 insertions(+), 1 deletion(-)

Acked-by: Rob Herring <robh@kernel.org>
