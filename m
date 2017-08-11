From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net-next] hns3pf: fix hns3_del_tunnel_port()
Date: Fri, 11 Aug 2017 14:32:49 -0700 (PDT)
Message-ID: <20170811.143249.1660948289275185489.davem@davemloft.net>
References: <20170810090720.eh4l6gxsubmwqxo6@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com, jiri@mellanox.com,
        jhs@mojatatu.com, lipeng321@huawei.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170810090720.eh4l6gxsubmwqxo6@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 10 Aug 2017 12:54:59 +0300

> This function has a copy and paste bug so it accidentally calls the add
> function instead of the delete function.
> 
> Fixes: 76ad4f0ee747 ("net: hns3: Add support of HNS3 Ethernet Driver for hip08 SoC")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
