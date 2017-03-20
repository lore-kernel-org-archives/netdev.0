From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH] mlxsw: spectrum: fix swapped order of arguments packets
 and bytes
Date: Mon, 20 Mar 2017 14:16:19 +0200
Message-ID: <20170320121619.GA12091@splinter.mtl.com>
References: <20170320113722.30311-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170320113722.30311-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 20, 2017 at 11:37:22AM +0000, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The arguments packets and bytes to call mlxsw_sp_acl_rule_get_stats are
> in the wrong order. Fix this by swapping them.
> 
> Detected by CoverityScan, CID#1419705 ("Arguments in wrong order")
> 
> Fixes: 7c1b8eb175b69add8ea ("mlxsw: spectrum: Add support for TC flower offload statistics")

Only need first 12 characters.

> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Acked-by: Ido Schimmel <idosch@mellanox.com>

Thanks!
