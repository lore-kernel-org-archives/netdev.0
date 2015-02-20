From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] hso: always read interface number from the current
 altsetting
Date: Fri, 20 Feb 2015 15:21:56 -0500 (EST)
Message-ID: <20150220.152156.1455455304724247882.davem@davemloft.net>
References: <1424169089-25039-1-git-send-email-aleksander@aleksander.es>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1424169089-25039-1-git-send-email-aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
Date: Tue, 17 Feb 2015 11:31:29 +0100

> Always read bInterfaceNumber from the current altsetting, not from the first one
> available in the altsetting array. This is coming from code review, not related
> to any specific bug.
> 
> Signed-off-by: Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
