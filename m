From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] usbnet: runtime pm: fix out of memory
Date: Thu, 05 May 2011 10:39:59 -0700 (PDT)
Message-ID: <20110505.103959.226761823.davem@davemloft.net>
References: <201105030953.44131.oneukum@suse.de>
	<BANLkTinZK_qjO7u+ckG_83_paVyMeyrgPw@mail.gmail.com>
	<201105040926.12355.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: oneukum-l3A5Bk7waGM@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201105040926.12355.oneukum-l3A5Bk7waGM@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Date: Wed, 4 May 2011 09:26:12 +0200

> Am Mittwoch, 4. Mai 2011, 08:59:41 schrieb Ming Lei:
>> Hi,
>> 
>> 2011/5/3 Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>:
>> 
>> > Do the devices in question use cdc_ether?
>> 
>> No, the device is smsc95xx, which is compound device and is
>> integrated into pandaboard.
> 
> OK,
> 
> in this case:
> 
> Acked-by: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
