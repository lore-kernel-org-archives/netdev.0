From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2] hso: Use static attribute groups for sysfs entry
Date: Thu, 05 Feb 2015 15:52:01 -0800 (PST)
Message-ID: <20150205.155201.1794305921895194040.davem@davemloft.net>
References: <1423131324-7379-1-git-send-email-tiwai@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: tiwai-l3A5Bk7waGM@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1423131324-7379-1-git-send-email-tiwai-l3A5Bk7waGM@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>
Date: Thu,  5 Feb 2015 11:15:24 +0100

> Pass the static attribute groups and the driver data via
> tty_port_register_device_attr() instead of manual device_create_file()
> and device_remove_file() calls.
> 
> Signed-off-by: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>
> ---
> v1->v2: rebased to linux-next

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
