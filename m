From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V3 net-next] net: hns3: Add support to change MTU in HNS3
 hardware
Date: Mon, 21 Aug 2017 16:29:39 +0200
Message-ID: <20170821142939.GG1703@lunn.ch>
References: <20170821101223.111852-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, yisen.zhuang@huawei.com, lipeng321@huawei.com,
        mehta.salil.lnk@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org,
        linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170821101223.111852-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2017 at 11:12:23AM +0100, Salil Mehta wrote:
> This patch adds the following support to the HNS3 driver:
> 1. Support to change the Maximum Transmission Unit of a
>    of a port in the HNS NIC hardware.
> 2. Initializes the supported MTU range for the netdevice.
> 
> Signed-off-by: lipeng <lipeng321@huawei.com>
> Signed-off-by: Salil Mehta <salil.mehta@huawei.com>

Hi Salil

Apart from Leon comments.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
