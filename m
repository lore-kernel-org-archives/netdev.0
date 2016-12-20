From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx5: use rb_entry()
Date: Tue, 20 Dec 2016 14:23:29 -0500 (EST)
Message-ID: <20161220.142329.503730398113255914.davem@davemloft.net>
References: <ddabc96c798df194791134d8e070d728e2a7b59f.1482203698.git.geliangtang@gmail.com>
        <8443fa3fa03d82c2b829375d8020762e5236dc6d.1482203930.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: geliangtang@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8443fa3fa03d82c2b829375d8020762e5236dc6d.1482203930.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geliang Tang <geliangtang@gmail.com>
Date: Tue, 20 Dec 2016 22:02:14 +0800

> To make the code clearer, use rb_entry() instead of container_of() to
> deal with rbtree.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>

Applied.
