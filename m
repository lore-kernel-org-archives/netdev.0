From: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
Subject: Re: WARNING: CPU: 2 PID: 682 at net/wireless/util.c:1236
Date: Thu, 4 May 2017 09:27:30 -0600
Message-ID: <4ad7a627-62c7-be34-2dae-c54bb3ef0a15@kernel.dk>
References: <240bae44-56e4-f342-0d1b-358a573e2eeb@kernel.dk>
 <20170504.112512.833061289089590605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170504.112512.833061289089590605.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/04/2017 09:25 AM, David Miller wrote:
> From: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
> Date: Thu, 4 May 2017 09:23:36 -0600
> 
>> Running current -git on my laptop, and I see this spew every once
>> in a while. This is new, haven't seen it in 4.11 or previously. Driver
>> is iwlwifi:
> 
> Please try:
> 
> http://patchwork.ozlabs.org/patch/758364/

Will do, compiling...

-- 
Jens Axboe
