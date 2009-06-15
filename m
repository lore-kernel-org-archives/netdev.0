From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: rfkill regression in net-next-2.6
Date: Mon, 15 Jun 2009 08:04:23 -0400
Message-ID: <20090615120422.GA2729@tuxdriver.com>
References: <20090604152011.GC2839@tuxdriver.com> <20090607.033751.191866033.davem@davemloft.net> <4A2BCC41.1060508@hartkopp.net> <20090607145830.GA2736@tuxdriver.com> <4A2BD8A5.4040302@hartkopp.net> <1244388583.23850.87.camel@localhost.localdomain> <4A34BAB9.9000104@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A34BAB9.9000104-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 14, 2009 at 10:54:17AM +0200, Oliver Hartkopp wrote:

> Any idea what changed in net-next-2.6 that could produce this behaviour?

The rfkill subsystem rewrite would seem suspect... :-)

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
