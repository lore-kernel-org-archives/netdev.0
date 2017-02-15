From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 0/8] net: stmmac: misc patchs
Date: Wed, 15 Feb 2017 10:11:48 +0100
Message-ID: <b3797a9e-5cdf-2d3d-0686-e1d9185c3554@st.com>
References: <20170214195441.30425-1-clabbe.montjoie@gmail.com>
 <241535e2-36fb-d3f7-5da8-289c1c1bbcc6@st.com> <20170215073910.GA12040@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <alexandre.torgue@st.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170215073910.GA12040@Red>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/15/2017 8:39 AM, Corentin Labbe wrote:
> Since all patch in v2 already hit linux-next, I just want to be sure, I can add "Acked-by and Reviewed-by" to thoses 8 new patchs ?

Right I have just seen the V2 patches are in net-next.

pls consider, for this set, my

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>


Regards
Peppe

>
> Regards
>
>>>
>>> Corentin Labbe (8):
>>>   net: stmmac: remove useless parenthesis
>>>   net: stmmac: likely is useless in occasional function
>>>   net: stmmac: use SPEED_UNKNOWN/DUPLEX_UNKNOWN
>>>   net: stmmac: set speed at SPEED_UNKNOWN in case of broken speed
>>>   net: stmmac: run stmmac_hw_fix_mac_speed when speed is valid
>>>   net: stmmac: split the stmmac_adjust_link 10/100 case
>>>   net: stmmac: reduce indentation by adding a continue
>>>   net: stmmac: invert the logic for dumping regs
>>>
>>>  .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   | 18 ++---
>>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 40 ++++++-----
>>>  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  | 82 +++++++++++-----------
>>>  3 files changed, 71 insertions(+), 69 deletions(-)
>>>
>>
>
