From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2] drivers: net: Fix dependency for EEPROM_93CX6
Date: Thu, 05 Jan 2012 14:21:52 -0500 (EST)
Message-ID: <20120105.142152.1306829639610242754.davem@davemloft.net>
References: <CAOMZO5AuZ_MHW3C1uNK7PyRz=XRHXhn2pvKCwk7iXLDd0YkDOQ@mail.gmail.com>
	<CAOMZO5DTDpp8+9FOjPXGFQtQPg7Pv5qfAwFO3UC6AUdEDgpHYg@mail.gmail.com>
	<1325791078.3764.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: festevam-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	fabio.estevam-KZfg59tc24xl57MIdRCFDg@public.gmane.org
To: bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1325791078.3764.30.camel@bwh-desktop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Date: Thu, 5 Jan 2012 19:17:58 +0000

> Right, you'll have to delete all dependencies on MISC_DEVICES.  Maybe
> remove it from defconfigs as well, though I'm not sure whether it's
> normal to do that at the same time.

defconfigs are usually left to the arch maintainers to update.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
