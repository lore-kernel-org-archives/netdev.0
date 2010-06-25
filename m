From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] Bluetooth: Bring back var 'i' increment
Date: Thu, 24 Jun 2010 22:08:51 -0700 (PDT)
Message-ID: <20100624.220851.68145958.davem@davemloft.net>
References: <20100619002213.GC14514@vigoh>
	<1276907040-23229-1-git-send-email-padovan@profusion.mobi>
	<20100619002807.GD14514@vigoh>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org
To: gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100619002807.GD14514@vigoh>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
Date: Fri, 18 Jun 2010 21:28:07 -0300

> * Gustavo F. Padovan <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org> [2010-06-18 21:24:00 -0300]:
> 
>> commit ff6e2163f28a1094fb5ca5950fe2b43c3cf6bc7a accidentally added a
>> regression on the bnep code. Fixing it.
>> 
>> Signed-off-by: Gustavo F. Padovan <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
 ...
> Marcel, if you want I can carry the fix on my tree for -next.

I'll apply this bug fix to net-2.6 so it doesn't just rot like it is
currently.

Thanks.
