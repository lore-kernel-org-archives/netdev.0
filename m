From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH] net/mlx4: fix spelling mistake: "enforcment" ->
 "enforcement"
Date: Tue, 27 Jun 2017 13:33:52 +0300
Message-ID: <2a0ff12b-69f9-8b20-9c0e-6602f935b838@mellanox.com>
References: <20170627100243.15956-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr00089.outbound.protection.outlook.com ([40.107.0.89]:51024
        "EHLO EUR02-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751699AbdF0KeH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Jun 2017 06:34:07 -0400
In-Reply-To: <20170627100243.15956-1-colin.king@canonical.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 27/06/2017 1:02 PM, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Trivial fix to spelling mistake in mlx4_dbg debug message
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/cmd.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
> index c1af47e45d3f..9e4c142c7ecd 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
> @@ -3280,7 +3280,7 @@ int mlx4_set_vf_link_state(struct mlx4_dev *dev, int port, int vf, int link_stat
>   
>   	if (mlx4_master_immediate_activate_vlan_qos(priv, slave, port))
>   		mlx4_dbg(dev,
> -			 "updating vf %d port %d no link state HW enforcment\n",
> +			 "updating vf %d port %d no link state HW enforecment\n",
Hi Colin,
You still have a typo. It's "enforcement".
>   			 vf, port);
>   	return 0;
>   }
> 
