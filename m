From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [PATCH][V2] net/mlx4: fix spelling mistake: "enforcment" ->
 "enforcement"
Date: Tue, 27 Jun 2017 14:37:58 +0300
Message-ID: <f21314ac-ec0d-5529-d2b0-12616fb5f45c@mellanox.com>
References: <20170627103649.16619-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Colin King <colin.king@canonical.com>,
        Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170627103649.16619-1-colin.king@canonical.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 27/06/2017 1:36 PM, Colin King wrote:
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
> +			 "updating vf %d port %d no link state HW enforcement\n",
>   			 vf, port);
>   	return 0;
>   }
> 
Acked-by: Tariq Toukan <tariqt@mellanox.com>

Thanks Colin.
