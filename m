From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH NET V7 1/2] net: phy: Add phy loopback support in net phy
 framework
Date: Wed, 28 Jun 2017 15:27:50 +0200
Message-ID: <20170628132750.GA12559@lunn.ch>
References: <1498641191-13343-1-git-send-email-linyunsheng@huawei.com>
 <1498641191-13343-2-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, f.fainelli@gmail.com,
        huangdaode@hisilicon.com, xuwei5@hisilicon.com,
        liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
        gabriele.paoloni@huawei.com, john.garry@huawei.com,
        linuxarm@huawei.com, salil.mehta@huawei.com, lipeng321@huawei.com,
        tremyfr@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Lin Yun Sheng <linyunsheng@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37830 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751776AbdF1N2N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Jun 2017 09:28:13 -0400
Content-Disposition: inline
In-Reply-To: <1498641191-13343-2-git-send-email-linyunsheng@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 28, 2017 at 05:13:10PM +0800, Lin Yun Sheng wrote:
> This patch add set_loopback in phy_driver, which is used by MAC
> driver to enable or disable phy loopback. it also add a generic
> genphy_loopback function, which use BMCR loopback bit to enable
> or disable loopback.
> 
> Signed-off-by: Lin Yun Sheng <linyunsheng@huawei.com>

Hi Lin

It is normal to include my

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

when resubmitting a patch. The only time you drop such tags is when
you make a big change.

    Andrew
