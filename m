From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH NET V5 1/2] net: phy: Add phy loopback support in net phy
 framework
Date: Mon, 26 Jun 2017 15:43:45 +0200
Message-ID: <20170626134345.GD2623@lunn.ch>
References: <1498443039-134503-1-git-send-email-linyunsheng@huawei.com>
 <1498443039-134503-2-git-send-email-linyunsheng@huawei.com>
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
Received: from vps0.lunn.ch ([178.209.37.122]:35160 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751101AbdFZNnv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Jun 2017 09:43:51 -0400
Content-Disposition: inline
In-Reply-To: <1498443039-134503-2-git-send-email-linyunsheng@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 26, 2017 at 10:10:38AM +0800, Lin Yun Sheng wrote:
> This patch add set_loopback in phy_driver, which is used by Mac
> driver to enable or disable a phy. it also add a generic
> genphy_loopback function, which use BMCR loopback bit to enable
> or disable a phy.
> 
> Signed-off-by: Lin Yun Sheng <linyunsheng@huawei.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
