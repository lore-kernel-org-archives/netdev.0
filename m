From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlxsw: make mlxsw_config_profile const
Date: Fri, 11 Aug 2017 14:57:15 -0700 (PDT)
Message-ID: <20170811.145715.872937428159584655.davem@davemloft.net>
References: <1502458842-31516-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, jiri@mellanox.com, idosch@mellanox.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bhumirks@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502458842-31516-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Fri, 11 Aug 2017 19:10:42 +0530

> Make these structures const as they only stored in the profile field of
> a mlxsw_driver structure, which is of type const.
> Done using Coccinelle.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Applied to net-next.
