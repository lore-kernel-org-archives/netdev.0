From: Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [for-next 5/6] net/mlx5: Bump driver version
Date: Fri, 26 May 2017 08:56:35 -0400
Message-ID: <3733699c-480b-a1aa-14e1-4f27f86cfead@intel.com>
References: <20170523114404.20387-1-saeedm@mellanox.com>
 <20170523114404.20387-6-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170523114404.20387-6-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 5/23/2017 7:44 AM, Saeed Mahameed wrote:
> From: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> 
> Remove date and bump version for mlx5_core driver.
> 
> Signed-off-by: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

So I just complained about the bnxt_re doing this. I guess I need to 
raise a flag here too. Now to be clear I'm not against doing this 
version stuff. I'm against using it for some internal tracking that is 
meaningless to the kernel community.

There is no detail in your commit message as to what this driver version 
is used for. Can you please explain how your use of driver version is 
valid while theirs is not?

I realize Dave has already pulled this and I'm not asking for it to be 
reverted but maybe some discussion will help guide future patch 
submissions which do this stuff.

-Denny
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
