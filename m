From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: Re: [PATCH net-next 13/14] usbnet: kaweth: Use net_device_stats
 from struct net_device
Date: Tue, 11 Apr 2017 11:15:28 +0200
Message-ID: <1491902128.20341.6.camel@suse.com>
References: <20170407081739.5243-1-tklauser@distanz.ch>
         <20170407081739.5243-14-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170407081739.5243-14-tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Freitag, den 07.04.2017, 10:17 +0200 schrieb Tobias Klauser:
> Instead of using a private copy of struct net_device_stats in struct
> kaweth_device, use stats from struct net_device. Also remove the now
> unnecessary .ndo_get_stats function.
> 
> Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>
Acked-by: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
