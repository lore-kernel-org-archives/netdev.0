From: Gavin McCullagh <gavin.mccullagh-4eIRXPAgDeg@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: Fix code for spec changes of 2/7/2007
Date: Tue, 27 Feb 2007 17:00:00 +0000
Message-ID: <20070227170000.GZ12087@nuim.ie>
References: <45cca236.+lL/rsW3DbM3elnk%Larry.Finger@lwfinger.net>
 <45CCCAE1.9080901@lwfinger.net> <20070209213239.GA11650@srcf.ucam.org>
 <200702100655.51495.mb@bu3sch.de> <20070210125707.GA21803@srcf.ucam.org>
Reply-To: Gavin McCullagh <gavin.mccullagh-4eIRXPAgDeg@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Joseph Jezak <josejx-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <20070210125707.GA21803-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>
Content-disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On Sat, 10 Feb 2007, Matthew Garrett wrote:

> On Sat, Feb 10, 2007 at 06:55:50AM +0100, Michael Buesch wrote:
> 
> > It's likely that old cards still work with v4 firmware, but we don't know and
> > it has to be tested.
> > 
> > Care to do so?
> 
> I'll check the revision of my 4306, but I think it's probably too new to 
> be useful, unfortunately...

I have a fairly old 4306 at home which I was lent by my boss and I've been
struggling to get it working for the past week or two.  What I find is that
loads of firmwares which I try with bcm43xx-fwcutter complain about the
firmware being old but then when I get a firmware which is not too old the
device registers but doesn't seem to work -- iwlist can't see any access
points and when I set the essid it doesn't associate with the AP.

Can I be helpful as a tester?

Gavin
