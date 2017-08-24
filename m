From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx4_core: make mlx4_profile const
Date: Thu, 24 Aug 2017 12:33:48 -0700 (PDT)
Message-ID: <20170824.123348.937333597620049659.davem@davemloft.net>
References: <1503492459-3110-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, tariqt@mellanox.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: bhumirks@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503492459-3110-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Wed, 23 Aug 2017 18:17:39 +0530

> Make these const as they are only used in a copy operation.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Applied to net-next.
