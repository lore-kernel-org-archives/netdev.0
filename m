From: Heiko Stuebner <heiko@sntech.de>
Subject: Re: [PATCH v4 6/6] arm64: dts: rockchip: enable the gmac for rk3399 evb board
Date: Wed, 07 Sep 2016 20:16:47 +0200
Message-ID: <1587027.EOPyfRoxyJ@phil>
References: <1472752204-8924-1-git-send-email-wxt@rock-chips.com> <1472752204-8924-7-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-rockchip@lists.infradead.org,
        Brian Norris <briannorris@chromium.org>,
        Douglas Anderson <dianders@chromium.org>,
        dbasehore@chromium.org, Roger Chen <roger.chen@rock-chips.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Frank Wang <frank.wang@rock-chips.com>,
        Jianqun Xu <jay.xu@rock-chips.com>, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Caesar Wang <wxt@rock-chips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472752204-8924-7-git-send-email-wxt@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag, 2. September 2016, 01:50:04 CEST schrieb Caesar Wang:
> From: Roger Chen <roger.chen@rock-chips.com>
> 
> We add the required and optional properties for evb board.
> See the [0] to get the detail information.
> 
> [0]:
> Documentation/devicetree/bindings/net/rockchip-dwmac.txt
> 
> Signed-off-by: Roger Chen <roger.chen@rock-chips.com>
> Signed-off-by: Caesar Wang <wxt@rock-chips.com>

applied to my dts64 branch,

after moving clkin_gmac and sorting the gmac properties according to their 
alphabetical position.


Heiko
