From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] hso: fix for the 'invalid frame length' messages
Date: Thu, 02 Apr 2009 01:36:25 -0700 (PDT)
Message-ID: <20090402.013625.104528245.davem@davemloft.net>
References: <20090330094459.GC9849@raptor>
	<20090402.012032.67869929.davem@davemloft.net>
	<49D4787A.6060808@option.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <49D4787A.6060808-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Date: Thu, 02 Apr 2009 10:34:02 +0200

> Against which sources should I take them again and should I start
> from the same clean sources for each patch or can they be "stacked"
> ?

When you have multiple patches, you number them, and they
are applied in that series order.

You can work against:

	git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
