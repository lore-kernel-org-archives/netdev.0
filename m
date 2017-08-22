From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4 net-next] net: hns3: Add support to change MTU in
 HNS3 hardware
Date: Tue, 22 Aug 2017 11:03:07 -0700 (PDT)
Message-ID: <20170822.110307.279487074369438712.davem@davemloft.net>
References: <20170821160524.32760-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, lipeng321@huawei.com,
        mehta.salil.lnk@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org,
        linuxarm@huawei.com
To: salil.mehta@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170821160524.32760-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Salil Mehta <salil.mehta@huawei.com>
Date: Mon, 21 Aug 2017 17:05:24 +0100

> This patch adds the following support to the HNS3 driver:
> 1. Support to change the Maximum Transmission Unit of a
>    port in the HNS NIC hardware.
> 2. Initializes the supported MTU range for the netdevice.
> 
> Signed-off-by: lipeng <lipeng321@huawei.com>
> Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> Reviewed-by: Leon Romanovsky <leonro@mellanox.com>

Applied.
