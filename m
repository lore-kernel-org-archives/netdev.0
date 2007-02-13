From: Ismail =?iso-8859-1?q?D=F6nmez?= <ismail-caicS1wCkhO6A22drWdTBw@public.gmane.org>
Subject: Re: [ANNOUNCE] d80211 based driver for Intel PRO/Wireless 3945ABG
Date: Tue, 13 Feb 2007 15:58:47 +0200
Message-ID: <200702131558.48987.ismail@pardus.org.tr>
References: <45CCE3CA.4050904@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <45CCE3CA.4050904-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 09 February 2007 23:12:42 James Ketrenos wrote:
> Please hold all questions until I am done with this email.  Thank you.
>
> We are pleased to announce the availability of a new driver for the
> Intel PRO/Wireless 3945ABG Network Connection adapter.  This new driver
> uses the new d80211 subsystem previously only available as part of the
> wireless-dev tree.
>
> You can find the new driver, and additional information about it, here:
>
>    http://intellinuxwireless.org/iwlwifi.

Tried this is on a patched 2.6.20 kernel with ipw3945 device and it always 
puts the card in 802.11a mode instead of 802.11bg mode.

Ideas?

Regards,
ismail
-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
