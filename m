From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [RFC] updated Patch to option HSO driver to the kernel
Date: Mon, 21 Apr 2008 13:17:23 -0700
Message-ID: <200804211317.23971.david-b@pacbell.net>
References: <20080417214719.GF17664@kroah.com> <480BE815.2000409@teltonika.lt> <480CB8C2.9090902@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <480CB8C2.9090902-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 21 April 2008, Paulius Zaleckas wrote:
> 
> Incremental patch.
> - Remove multicasting

Is it really a good idea to remove the ability to
use DHCP over these links?

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
