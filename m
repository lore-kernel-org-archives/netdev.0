From: "Gary Zambrano" <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: Merging SSB upstream
Date: Mon, 07 May 2007 09:43:18 -0700
Message-ID: <1178556198.8350.2.camel@dhcp-10-12-136-115.broadcom.com>
References: <200705060303.17594.mb@bu3sch.de>
 <463D4770.9060903@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael Buesch" <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	"John Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: "Jeff Garzik" <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <463D4770.9060903-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-05-05 at 23:11 -0400, Jeff Garzik wrote:
> Michael Buesch wrote:
> > So, now that mac80211 is merged upstream, I think it's
> > time to merge SSB and the b44-ssb port upstream.
> > Note that bcm43xx-mac80211 is _not_ ready for upstream, yet.
> > 
> > What do you think? I'd like to merge ssb as-is, although
> > the embedded-device parts are not quite finished, yet.
> > But they don't interfere with the non-embedded parts used
> > by b44 and the bcm43xx PCI cards.
> > So we _could_ remove the ssb-mips code, but I don't like to
> > do that for better maintainability. It doesn't hurt anyone IMO.
> 
> What does Ralf (MIPS maintainer) and Gary (Broadcom maintainer) think?
> 
> For my part, I'm not going to render even a tentative opinion without a 
> link to actual code.
> 
> Last I saw of the code, and descriptions in IRC, it sounded sane.
> 
> 	Jeff
> 

I would like to put some test mileage behind the ssb.
We had a hard time testing it a while back, so we will try the latest.
Thanks,
Gary
