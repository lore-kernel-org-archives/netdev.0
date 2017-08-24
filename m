From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx5e: make mlx5e_profile const
Date: Thu, 24 Aug 2017 12:33:54 -0700 (PDT)
Message-ID: <20170824.123354.243322923931424137.davem@davemloft.net>
References: <1503492721-3187-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, saeedm@mellanox.com, matanb@mellanox.com,
        leonro@mellanox.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: bhumirks@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503492721-3187-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Wed, 23 Aug 2017 18:22:01 +0530

> Make this const as it is only passed as an argument to the function
> mlx5e_create_netdev and the corresponding argument is of type const.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Applied to net-next.
