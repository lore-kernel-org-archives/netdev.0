From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: Merging SSB upstream
Date: Sat, 05 May 2007 23:11:44 -0400
Message-ID: <463D4770.9060903@garzik.org>
References: <200705060303.17594.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200705060303.17594.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> So, now that mac80211 is merged upstream, I think it's
> time to merge SSB and the b44-ssb port upstream.
> Note that bcm43xx-mac80211 is _not_ ready for upstream, yet.
> 
> What do you think? I'd like to merge ssb as-is, although
> the embedded-device parts are not quite finished, yet.
> But they don't interfere with the non-embedded parts used
> by b44 and the bcm43xx PCI cards.
> So we _could_ remove the ssb-mips code, but I don't like to
> do that for better maintainability. It doesn't hurt anyone IMO.

What does Ralf (MIPS maintainer) and Gary (Broadcom maintainer) think?

For my part, I'm not going to render even a tentative opinion without a 
link to actual code.

Last I saw of the code, and descriptions in IRC, it sounded sane.

	Jeff
