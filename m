From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: Merging SSB upstream
Date: Sun, 6 May 2007 11:44:27 +0200
Message-ID: <200705061144.27817.mb@bu3sch.de>
References: <200705060303.17594.mb@bu3sch.de> <20070506020051.GA30917@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070506020051.GA30917-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 06 May 2007 04:00:51 John W. Linville wrote:
> On Sun, May 06, 2007 at 03:03:17AM +0200, Michael Buesch wrote:
> > So, now that mac80211 is merged upstream, I think it's
> > time to merge SSB and the b44-ssb port upstream.
> > Note that bcm43xx-mac80211 is _not_ ready for upstream, yet.
>  
> ACK, unfortunately.
> 
> > What do you think? I'd like to merge ssb as-is, although
> > the embedded-device parts are not quite finished, yet.
> > But they don't interfere with the non-embedded parts used
> > by b44 and the bcm43xx PCI cards.
> 
> How much testing have you (and others) done w/ b44?

Well, it works for me with my b44 card I got from broadcom.
There are really only 2 or 3 different b44 cards, so chances are damn
high it will work for all.

> I had to remove 
> the b44 ssb changes from fedora because a) users reported problems;

Which problems were that? The 2 compile issues?
Trivial to fix if that's the only issue. ;)

-- 
Greetings Michael.
