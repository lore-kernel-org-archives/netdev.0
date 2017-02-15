From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 0/8] net: stmmac: misc patchs
Date: Wed, 15 Feb 2017 07:34:41 +0100
Message-ID: <241535e2-36fb-d3f7-5da8-289c1c1bbcc6@st.com>
References: <20170214195441.30425-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Corentin Labbe <clabbe.montjoie@gmail.com>,
        <alexandre.torgue@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170214195441.30425-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Corentin

On 2/14/2017 8:54 PM, Corentin Labbe wrote:
> Hello
>
> This is a follow up of my previous stmmac serie which address some comment
> done in v2.

I wonder if you can resend all the patches as V3
please add the Acked-by and Reviewed-by. This will help
on final review and integration.

Thx for your support and effort

Peppe

>
> Corentin Labbe (8):
>   net: stmmac: remove useless parenthesis
>   net: stmmac: likely is useless in occasional function
>   net: stmmac: use SPEED_UNKNOWN/DUPLEX_UNKNOWN
>   net: stmmac: set speed at SPEED_UNKNOWN in case of broken speed
>   net: stmmac: run stmmac_hw_fix_mac_speed when speed is valid
>   net: stmmac: split the stmmac_adjust_link 10/100 case
>   net: stmmac: reduce indentation by adding a continue
>   net: stmmac: invert the logic for dumping regs
>
>  .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   | 18 ++---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 40 ++++++-----
>  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  | 82 +++++++++++-----------
>  3 files changed, 71 insertions(+), 69 deletions(-)
>
