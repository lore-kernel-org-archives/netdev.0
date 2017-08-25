From: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/7] RDS: make rhashtable_params const
Date: Fri, 25 Aug 2017 08:31:36 -0700
Message-ID: <b3b84569-90d8-4f02-e79d-f7aacc07271a@oracle.com>
References: <1503670907-23221-1-git-send-email-bhumirks@gmail.com>
 <1503670907-23221-6-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, julia.lawall-L2FTfq7BK8M@public.gmane.org,
        marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org, johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org,
        fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org,
        yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org,
        anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
        jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
        bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
        linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1503670907-23221-6-git-send-email-bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

8/25/2017 7:21 AM, Bhumika Goyal wrote:
> Make this const as it is either used during a copy operation or passed
> to a const argument of the function rhltable_init
> 
> Signed-off-by: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
Acked-by: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
