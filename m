From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] hso: add new device id's
Date: Mon, 02 Feb 2009 14:02:40 -0800 (PST)
Message-ID: <20090202.140240.230022378.davem@davemloft.net>
References: <49870A39.8000806@option.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh-l3A5Bk7waGM@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <49870A39.8000806-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Date: Mon, 02 Feb 2009 15:59:05 +0100

> This patch adds a few device id's and removes one which will never be used.
> 
> Signed-off-by: Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>

Why won't 0xaf0/0xd051 ever be used?

You should explain such things in your commit message,
that way I don't have to ask.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
