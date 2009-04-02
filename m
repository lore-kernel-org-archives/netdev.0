From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 2/2] hso: fix for the 'invalid frame length' messages
Date: Thu, 02 Apr 2009 16:32:19 -0700 (PDT)
Message-ID: <20090402.163219.94094460.davem@davemloft.net>
References: <20090402085906.GB8663@raptor>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090402085906.GB8663@raptor>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Date: Thu, 2 Apr 2009 10:59:07 +0200

> Some devices cannot send very short usb transfers. To get around this the
> firmware adds a known pattern and flags the driver that it should check for
> this pattern on short transfers. This flag was not taken into account by
> the driver.
>     
> Signed-off-by: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
