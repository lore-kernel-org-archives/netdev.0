From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 00/11] Add the integrated PHY support
Date: Fri, 11 Aug 2017 14:29:15 -0700 (PDT)
Message-ID: <20170811.142915.2194989886100869835.davem@davemloft.net>
References: <1502373410-2423-1-git-send-email-david.wu@rock-chips.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: heiko@sntech.de, andrew@lunn.ch, f.fainelli@gmail.com,
        robh+dt@kernel.org, mark.rutland@arm.com, catalin.marinas@arm.com,
        will.deacon@arm.com, olof@lixom.net, linux@armlinux.org.uk,
        arnd@arndb.de, peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, hwg@rock-chips.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: david.wu@rock-chips.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502373410-2423-1-git-send-email-david.wu@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Wu <david.wu@rock-chips.com>
Date: Thu, 10 Aug 2017 21:56:39 +0800

> The rk3228 and rk3328 support integrated PHY inside, let's enable
> it to work. And the integrated PHY need to do some special setting,
> so register the rockchip integrated PHY driver.

Series applied to net-next, thanks.
