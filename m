From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [pull request][for-next 0/8] Mellanox, mlx5 shared 2017-08-07
Date: Mon, 7 Aug 2017 22:31:18 +0300
Message-ID: <CALzJLG8rbapMeQaf-fuv+i6ob22qG4xmv=2vYk0KJruhtVu+Rg@mail.gmail.com>
References: <20170807101808.22924-1-saeedm@mellanox.com> <20170807.112052.332868856082904160.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170807.112052.332868856082904160.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 7, 2017 at 9:20 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Date: Mon,  7 Aug 2017 13:18:00 +0300
>
>> Hi Dave & Doug,
>>
>> This series contains some low level updates for mlx5 core driver,
>> to be shared as base code for net-next and rdma for-next mlx5
>> 4.14 submissions.
>>
>> Please find more information in the tag message below.
>>
>> Please pull and let me know if there's any porblem.
>>
>> Side note:
>> This series merges cleanly with current net-next, but it will conflict with Jiri's patch
>> "mlx5e: push cls_flower and mqprio setup_tc processing into separate functions"
>> Which is under review.
>> since this is shared code and must go to both rdma and net-next it has to be
>> based on 4.13-rc4, so there is not much I can do about this.
>
> I resolved the merge conflict as best as I could, please take a look.
>

Thanks Dave!

looks good, I will do some compilation testing later and if i find
anything i will post a patch.

Thanks a lot,
-Saeed.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
