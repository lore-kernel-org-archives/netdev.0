From: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] rds: Remove unused rds_conn_error
Date: Sat, 15 Oct 2016 12:38:04 -0700
Message-ID: <0b5fac0d-5818-1eee-6af7-2d5f5881139e@oracle.com>
References: <cover.1476557523.git.joe@perches.com>
 <01fddf3af8f7757d0e79e4f25d7eb8b246e3d695.1476557523.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <01fddf3af8f7757d0e79e4f25d7eb8b246e3d695.1476557523.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/15/2016 11:53 AM, Joe Perches wrote:
> This macro's last use was removed in commit d769ef81d5b59
> ("RDS: Update rds_conn_shutdown to work with rds_conn_path")
> so make the macro and the __rds_conn_error function definition
> and declaration disappear.
>
> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
> ---
Had same patch along with few more in the queue but
didn't find time of late to get it on the list.
Thanks for both patches.

Acked-by: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
