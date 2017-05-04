From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: WARNING: CPU: 2 PID: 682 at net/wireless/util.c:1236
Date: Thu, 04 May 2017 11:59:27 -0400 (EDT)
Message-ID: <20170504.115927.311620488504377288.davem@davemloft.net>
References: <20170504.112512.833061289089590605.davem@davemloft.net>
        <4ad7a627-62c7-be34-2dae-c54bb3ef0a15@kernel.dk>
        <b25325a9-ab93-1c57-3b59-2d52a76d279a@kernel.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <b25325a9-ab93-1c57-3b59-2d52a76d279a-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
Date: Thu, 4 May 2017 09:40:08 -0600

> On 05/04/2017 09:27 AM, Jens Axboe wrote:
>> On 05/04/2017 09:25 AM, David Miller wrote:
>>> From: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
>>> Date: Thu, 4 May 2017 09:23:36 -0600
>>>
>>>> Running current -git on my laptop, and I see this spew every once
>>>> in a while. This is new, haven't seen it in 4.11 or previously. Driver
>>>> is iwlwifi:
>>>
>>> Please try:
>>>
>>> http://patchwork.ozlabs.org/patch/758364/
>> 
>> Will do, compiling...
> 
> Yep works, thanks.

Thanks for testing.
