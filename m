From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: arc_emac: Add support for ndo_do_ioctl
 net_device_ops operation
Date: Thu, 03 Aug 2017 15:14:57 -0700 (PDT)
Message-ID: <20170803.151457.476643485478784462.davem@davemloft.net>
References: <20170803074903.19688-1-romain.perier@collabora.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: al.kochet@gmail.com, weiyongjun1@huawei.com, edumazet@google.com,
        peter.chen@nxp.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: romain.perier@collabora.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170803074903.19688-1-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Romain Perier <romain.perier@collabora.com>
Date: Thu,  3 Aug 2017 09:49:03 +0200

> This operation is required for handling ioctl commands like SIOCGMIIREG,
> when debugging MDIO registers from userspace.
> 
> This commit adds support for this operation.
> 
> Signed-off-by: Romain Perier <romain.perier@collabora.com>

Applied, thanks.
