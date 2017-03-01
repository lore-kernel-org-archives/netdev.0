From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net/mlx4: && vs & typo
Date: Wed, 01 Mar 2017 12:52:35 -0500 (EST)
Message-ID: <20170301.125235.1175480613831613770.davem@davemloft.net>
References: <20170228120215.GA27947@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yishaih@mellanox.com, eugenia@mellanox.com,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170228120215.GA27947@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 28 Feb 2017 15:02:15 +0300

> Bitwise & was obviously intended here.
> 
> Fixes: 745d8ae4622c ("net/mlx4: Spoofcheck and zero MAC can't coexist")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
