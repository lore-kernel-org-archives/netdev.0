From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/2] rtlwifi: Use is_zero_ether_addr, remove line
 continuation
Date: Sat, 17 Mar 2012 14:18:30 -0700 (PDT)
Message-ID: <20120317.141830.1341064825746942134.davem@davemloft.net>
References: <1d738d4a4dd61978f969ed4a43f2dd3717f51a19.1332011552.git.joe@perches.com>
	<4F64FECD.9000802@lwfinger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F64FECD.9000802-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Date: Sat, 17 Mar 2012 16:14:53 -0500

> On 03/17/2012 02:13 PM, Joe Perches wrote:
>> Use the normal kernel facilities and use %pM
>> to print the all zero mac address.
>>
>> Remove unnecessary line continuation.
>>
>> Signed-off-by: Joe Perches<joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
>> ---
>>   drivers/net/wireless/rtlwifi/cam.c |    5 ++---
>>   1 files changed, 2 insertions(+), 3 deletions(-)
> 
> ACKed-by: Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org
> 
> Is there a PATCH 2/2? I did not receive it.

It went to netdev only and was only for non-wireless networking
drivers.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
