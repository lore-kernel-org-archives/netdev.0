From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: Re: [PATCH 11/11] net: usb: usb: remove old api
 ethtool_{get|set}_settings
Date: Mon, 20 Mar 2017 07:40:37 +0100
Message-ID: <1489992037.1380.1.camel@suse.com>
References: <1489702737-2401-1-git-send-email-tremyfr@gmail.com>
         <1489702737-2401-12-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Philippe Reynes <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org,
        robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
        akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
        UNGLinuxDriver-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org, peter.chen-3arQi8VN3Tc@public.gmane.org, jarod-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        stefan.bruens-vA1bhqPz9FBZXbeN9DUtxg@public.gmane.org, steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org,
        jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489702737-2401-12-git-send-email-tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Donnerstag, den 16.03.2017, 23:18 +0100 schrieb Philippe Reynes:
> The function usbnet_{get|set}_settings is no longer used,
> so we remove it.
> 
> Signed-off-by: Philippe Reynes <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Acked-by: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
