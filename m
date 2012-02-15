From: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/1] usb: cdc-ncm: Increase maximum allowed datagram size
Date: Wed, 15 Feb 2012 15:40:00 +0100
Message-ID: <CAL_Kpj0oN883qGhAD2pO4zOHvYt1=VmQHOJx970UF0TcqG06OA@mail.gmail.com>
References: <1329230375-25508-1-git-send-email-toby.gray@realvnc.com>
	<20120214.144622.678577766818888054.davem@davemloft.net>
	<CAL_Kpj0VSu-ByUEwTeVG5-5psab3h38bTL=ot7vYD8A+Oeb_Ug@mail.gmail.com>
	<201202150953.20341.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org,
	oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201202150953.20341.oneukum-l3A5Bk7waGM@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 15, 2012 at 9:53 AM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
> Have you tried that under severe memory presssure?

Well, it is a simplistic view upon host configuration.
Developing of NCM spec was done with mind set, that host must be more
capable than device.

However, proposal above doesn't solve problem completely due to usbnet.
Currently I'm testing some improvements/fixes related to data handling
and driver latency with the plan to post it in the near future.

Regards,
Alexey
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
