From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH] can: rcar_canfd: Correct order of interrupt specifiers
Date: Wed, 30 Nov 2016 14:38:34 -0600
Message-ID: <20161130203834.iinxujdkegmd6fa7@rob-hp-laptop>
References: <1479908686-14028-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wolfgang Grandegger <wg@grandegger.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
        Chris Paterson <chris.paterson2@renesas.com>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1479908686-14028-1-git-send-email-geert+renesas@glider.be>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 23, 2016 at 02:44:46PM +0100, Geert Uytterhoeven wrote:
> According to both DTS (example and actual files), and Linux driver code,
> the first interrupt specifier should be the Channel interrupt, while the
> second interrupt specifier should be the Global interrupt.
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> ---
>  Documentation/devicetree/bindings/net/can/rcar_canfd.txt | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Acked-by: Rob Herring <robh@kernel.org>
