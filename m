From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 01/11] net: phy: Add rockchip phy driver support
Date: Tue, 27 Jun 2017 16:46:49 +0200
Message-ID: <20170627144649.GD9921@lunn.ch>
References: <1498192929-7519-1-git-send-email-david.wu@rock-chips.com>
 <1498192929-7519-2-git-send-email-david.wu@rock-chips.com>
 <20170624021910.GB4875@lunn.ch>
 <38394157-adae-3476-55f3-ab5838744033@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, heiko@sntech.de, robh+dt@kernel.org,
        mark.rutland@arm.com, catalin.marinas@arm.com, will.deacon@arm.com,
        olof@lixom.net, linux@armlinux.org.uk, arnd@arndb.de,
        f.fainelli@gmail.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, huangtao@rock-chips.com,
        hwg@rock-chips.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David.Wu" <david.wu@rock-chips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <38394157-adae-3476-55f3-ab5838744033@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> it has been licensed from somebody.

And does that somebody already have a driver for it? There is no point
adding a driver, if all you need to do is add the ID to another
driver.

	Andrew
