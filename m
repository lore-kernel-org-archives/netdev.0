From: jeffy <jeffy.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: Re: Bluetooth: might sleep error in hidp_session_thread
Date: Tue, 27 Jun 2017 17:43:51 +0800
Message-ID: <595228D7.1070807@rock-chips.com>
References: <7be134d7f9904082a35a9cc926ec24d3@HQMAIL106.nvidia.com> <594D0BDE.10102@rock-chips.com> <cc75d14021724c2d8b74a92482d67b7b@HQMAIL105.nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brian Norris <briannorris-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Douglas Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Johan Hedberg <johan.hedberg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Peter Hurley <peter-WaGBZJeGNqdsbIuE7sb01tBPR1lH4CV8@public.gmane.org>,
        Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
To: Rohit Vaswani <rvaswani-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
        "linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cc75d14021724c2d8b74a92482d67b7b-wO81nVYWzR5AOoK4uxnQ11aTQe2KTcn/@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Rohit,

On 06/24/2017 02:00 AM, Rohit Vaswani wrote:
> I don't have a way to reply back to the older message; but you can use by tested-by for the below patch and re-send:
>
ok, i've resent it, thanks for your test by~

and for replying to an old message, i've figured it out when i tried to 
do that recently:

1/ download the mbox file from the patchwork 
link(https://patchwork.kernel.org/patch/***)
2/ rename it to .mbox
3/ import into thunerbird(using ImportExportTools)

hope that helps ;)

> For patch: [v4,3/3] Bluetooth: hidp: fix possible might sleep error in hidp_session_thread
>
> Tested-by: Rohit Vaswani <rvaswani-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
>
> -Rohit
>
> -----Original Message-----
> From: jeffy [mailto:jeffy.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org]
> Sent: Friday, June 23, 2017 05:39
> To: Rohit Vaswani; linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: Brian Norris; Douglas Anderson; Johan Hedberg; Peter Hurley; Johan Hedberg; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; David S. Miller; Marcel Holtmann; Gustavo Padovan
> Subject: Re: Bluetooth: might sleep error in hidp_session_thread
>
> Hi Rohit,
>
> Thanx for your reply, and sorry to the delay, somehow your mail was marked as spam by the mail server :(
>
> On 06/13/2017 02:31 AM, Rohit Vaswani wrote:
>> Hi Jeffy,
>>
>> I was looking into the patch from Jeffy Chen from February 14 2017  :
>>    [v4,3/3] Bluetooth: hidp: fix possible might sleep error in
>> hidp_session_thread: https://patchwork.kernel.org/patch/9570931/
>>
>> We faced a similar issue and this patch seems to fix the problem in our preliminary test.
>> I am trying to check if there was a reason this wasn't merged earlier ?
>
> hmm, i'm not sure why, but please feel free to add your test-by~
>>
>> Thanks,
>> Rohit
>>
>> nvpublic
>>
>>
>>
>
>
