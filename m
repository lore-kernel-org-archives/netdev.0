From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 2/3] can: m_can: Update documentation to indicate that
 hclk may be optional
Date: Mon, 24 Jul 2017 14:20:29 -0500
Message-ID: <20170724192029.ou2oygcywxk66gjo@rob-hp-laptop>
References: <20170719230926.10872-1-fcooper@ti.com>
 <20170719230926.10872-3-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-can@vger.kernel.org,
        wg@grandegger.com, mkl@pengutronix.de,
        quentin.schulz@free-electrons.com
To: Franklin S Cooper Jr <fcooper@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170719230926.10872-3-fcooper@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 19, 2017 at 06:09:25PM -0500, Franklin S Cooper Jr wrote:
> Update the documentation to reflect that hclk is now an optional clock.
> 
> Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
> ---
>  Documentation/devicetree/bindings/net/can/m_can.txt | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)

Acked-by: Rob Herring <robh@kernel.org>
