From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH NET V7 0/2] Add loopback support in phy_driver and hns
 ethtool fix
Date: Thu, 29 Jun 2017 20:22:16 +0200
Message-ID: <20170629182216.GB17212@lunn.ch>
References: <1498641191-13343-1-git-send-email-linyunsheng@huawei.com>
 <20170629.141455.1338948120889824664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linyunsheng@huawei.com, f.fainelli@gmail.com,
        huangdaode@hisilicon.com, xuwei5@hisilicon.com,
        liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
        gabriele.paoloni@huawei.com, john.garry@huawei.com,
        linuxarm@huawei.com, salil.mehta@huawei.com, lipeng321@huawei.com,
        tremyfr@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170629.141455.1338948120889824664.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 29, 2017 at 02:14:55PM -0400, David Miller wrote:
> From: Lin Yun Sheng <linyunsheng@huawei.com>
> Date: Wed, 28 Jun 2017 17:13:09 +0800
> 
> > This Patch Set add set_loopback in phy_driver and use it to setup loopback
> > when doing ethtool phy self_test.
> 
> This doesn't apply cleanly to the net-next tree, please respin.

Hi David

This patchset still has issues. The first patch is O.K. to be
committed, but the second patch to the hns driver still has issues. I
suppose it makes the hns driver less broken, but it is still
broken. Is less broken a sufficient criteria for acceptance?

	Andrew
