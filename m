From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v5 02/10] dt-bindings: net: Restore sun8i dwmac binding
Date: Wed, 13 Sep 2017 13:07:34 -0500
Message-ID: <20170913180734.xvazvf7thpqtssgz@rob-hp-laptop>
References: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
 <20170908071156.5115-3-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mark.rutland@arm.com, maxime.ripard@free-electrons.com,
        wens@csie.org, linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, andrew@lunn.ch, f.fainelli@gmail.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170908071156.5115-3-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 08, 2017 at 09:11:48AM +0200, Corentin Labbe wrote:
> This patch restore dt-bindings documentation about dwmac-sun8i
> This reverts commit 8aa33ec2f481 ("dt-bindings: net: Revert sun8i dwmac binding")

Why?

> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
>  .../devicetree/bindings/net/dwmac-sun8i.txt        | 84 ++++++++++++++++++++++
>  1 file changed, 84 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/dwmac-sun8i.txt

Otherwise,

Acked-by: Rob Herring <robh@kernel.org>
