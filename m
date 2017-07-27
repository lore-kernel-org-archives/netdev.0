From: "David.Wu" <david.wu@rock-chips.com>
Subject: Re: [PATCH 05/11] net: stmmac: dwmac-rk: Add internal phy support
Date: Thu, 27 Jul 2017 20:44:42 +0800
Message-ID: <24bc9102-d37f-1a63-ad7b-f69e8e38d848@rock-chips.com>
References: <1498192929-7519-1-git-send-email-david.wu@rock-chips.com>
 <1498193947-8011-1-git-send-email-david.wu@rock-chips.com>
 <20170624022954.GD4875@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=gbk; format=flowed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, heiko@sntech.de, robh+dt@kernel.org,
        mark.rutland@arm.com, catalin.marinas@arm.com, will.deacon@arm.com,
        olof@lixom.net, linux@armlinux.org.uk, arnd@arndb.de,
        f.fainelli@gmail.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, huangtao@rock-chips.com,
        hwg@rock-chips.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170624022954.GD4875@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

ÔÚ 2017/6/24 10:29, Andrew Lunn Ð´µÀ:
> If this is the PHY clock, should it actually be specified in the PHY
> binding? Can you read the PHY ID registers with this clock off?
If the phy clock is closed, we can not read the PHYID.
