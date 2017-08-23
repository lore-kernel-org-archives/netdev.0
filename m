From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH] drivers: net: wireless: atmel: check memory allocation failure
Date: Wed, 23 Aug 2017 07:13:43 +0300
Message-ID: <87efs2yl8o.fsf@kamboji.qca.qualcomm.com>
References: <1503389481-4988-1-git-send-email-himanshujha199640@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Himanshu Jha <himanshujha199640-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1503389481-4988-1-git-send-email-himanshujha199640-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
        (Himanshu Jha's message of "Tue, 22 Aug 2017 13:41:21 +0530")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Himanshu Jha <himanshujha199640-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Check memory allocation failure and return -ENOMEM if failure
> occurs.
>
> Signed-off-by: Himanshu Jha <himanshujha199640-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

The title prefix is wrong:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches#commit_title_is_wrong

-- 
Kalle Valo
