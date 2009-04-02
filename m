From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/2] hso: fix for crash when unplugging the device
Date: Thu, 02 Apr 2009 16:32:13 -0700 (PDT)
Message-ID: <20090402.163213.117158278.davem@davemloft.net>
References: <20090402085720.GA8663@raptor>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090402085720.GA8663@raptor>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Date: Thu, 2 Apr 2009 10:57:20 +0200

> Changed the order in which things are freed. This fixes an oops when
> unplugging the device while network traffic is ongoing.
>     
> Signed-off-by: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
