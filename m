From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [RFC] updated Patch to option HSO driver to the kernel
Date: Fri, 25 Apr 2008 12:09:35 -0400
Message-ID: <20080425160935.GA9152@infradead.org>
References: <20080417214719.GF17664@kroah.com> <480F3C41.10908@teltonika.lt> <4811CF33.8040007@teltonika.lt> <200804251503.31240.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200804251503.31240.oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 25, 2008 at 03:03:30PM +0200, Oliver Neukum wrote:
> Am Freitag, 25. April 2008 14:31:47 schrieb Paulius Zaleckas:
> > - do we really need ethtool support? It always reports that
> > ?? ??link is up... The only useful information is driver name,
> > ?? ??version and USB path... Is it worth it?
> 
> Yes. NetworkManager does strange things to devices without ethtool
> support. NetworkManager is important.

So we hack around broken userspace in the kernel now?  What about using
your energy to fix up NetworkManager (yes, I know it's crap code, but
life is hard sometimes)

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
