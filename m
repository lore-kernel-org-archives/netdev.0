From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Tue, 15 Apr 2008 10:10:32 +0200
Message-ID: <200804151010.33688.oliver@neukum.org>
References: <20080414213238.GB28833@kroah.com> <fu0osk$887$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <fu0osk$887$1@ger.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 15. April 2008 01:20:51 schrieb Paulius Zaleckas:
> Greg KH wrote:
> > I'd like to see this go into 2.6.26, so any review comments by anyone
> > who wishes to review any portion of this would be greatly apprecited.
> 
> In attached patch I have rewrote MAC address generation to simple call
> to random_ether_addr instead of some mysterious pointer parsing :)

Could you please generate a kernel patch, not a patch against a patch?
I have difficulties dealing with that.

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
