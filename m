From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4_en: mlx4_en_verify_params() can be
 static
Date: Thu, 06 Mar 2014 16:54:21 -0500 (EST)
Message-ID: <20140306.165421.316751944344722461.davem@davemloft.net>
References: <1394013443-17153-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com, fengguang.wu@intel.com,
	linux-kernel@vger.kernel.org, eugenia@mellanox.com
To: amirv@mellanox.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394013443-17153-1-git-send-email-amirv@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amir Vadai <amirv@mellanox.com>
Date: Wed,  5 Mar 2014 11:57:23 +0200

> From: Fengguang Wu <fengguang.wu@intel.com>
> 
> Fix static error introduced by commit:
> b97b33a3df0439401f80f041eda507d4fffa0dbf [645/653] net/mlx4_en: Verify
> mlx4_en module parameters
> 
> sparse warnings:
> drivers/net/ethernet/mellanox/mlx4/en_main.c:335:6: sparse: symbol
> 'mlx4_en_verify_params' was not declared. Should it be static?
> 
> CC: netdev@vger.kernel.org
> CC: linux-kernel@vger.kernel.org
> CC: Eugenia Emantayev <eugenia@mellanox.com>
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Applied, thanks.
