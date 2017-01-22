From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx4: use rb_entry()
Date: Sun, 22 Jan 2017 16:48:01 -0500 (EST)
Message-ID: <20170122.164801.1506380782421645438.davem@davemloft.net>
References: <c6a809ea5820242a4ae126b03cdcd910a36e5cae.1484817152.git.geliangtang@gmail.com>
        <6c1c772de8f70113580dade04f89a377174d8c88.1484817025.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yishaih@mellanox.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: geliangtang@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6c1c772de8f70113580dade04f89a377174d8c88.1484817025.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geliang Tang <geliangtang@gmail.com>
Date: Fri, 20 Jan 2017 22:36:57 +0800

> To make the code clearer, use rb_entry() instead of container_of() to
> deal with rbtree.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>

Applied.
