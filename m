From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v2 1/9] net: stmmac: Rename clk_ptp_ref clock to ptp_ref
Date: Mon, 20 Mar 2017 10:18:55 -0500
Message-ID: <20170320151855.32siq45uta6jvjep@rob-hp-laptop>
References: <20170310163501.31811-1-thierry.reding@gmail.com>
 <20170310163501.31811-2-thierry.reding@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Jon Hunter <jonathanh@nvidia.com>,
        Mikko Perttunen <cyndis@kapsi.fi>, netdev@vger.kernel.org,
        linux-tegra@vger.kernel.org, linux-kernel@vger.kernel.org,
        Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org
To: Thierry Reding <thierry.reding@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170310163501.31811-2-thierry.reding@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 10, 2017 at 05:34:53PM +0100, Thierry Reding wrote:
> From: Thierry Reding <treding@nvidia.com>
> 
> There aren't currently any users of the "clk_ptp_ref", but there are
> other references to "ptp_ref", so I'm leaning towards considering that a
> typo. Fix it.
> 
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Rob Herring <robh+dt@kernel.org>
> Cc: devicetree@vger.kernel.org
> Signed-off-by: Thierry Reding <treding@nvidia.com>
> ---
>  Documentation/devicetree/bindings/net/stmmac.txt      | 6 +++---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 2 +-
>  2 files changed, 4 insertions(+), 4 deletions(-)

Acked-by: Rob Herring <robh@kernel.org>
