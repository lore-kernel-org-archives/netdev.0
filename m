From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: Fix code for spec changes of 2/7/2007
Date: Sat, 10 Feb 2007 06:55:50 +0100
Message-ID: <200702100655.51495.mb@bu3sch.de>
References: <45cca236.+lL/rsW3DbM3elnk%Larry.Finger@lwfinger.net> <45CCCAE1.9080901@lwfinger.net> <20070209213239.GA11650@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Joseph Jezak <josejx-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070209213239.GA11650-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 09 February 2007 22:32, Matthew Garrett wrote:
> On Fri, Feb 09, 2007 at 01:26:25PM -0600, Larry Finger wrote:
> 
> > My plan is to continue to maintain bcm43xx-SoftMAC for at least the BPHY and 4306 revisions even
> > after d80211 becomes the in-kernel driver. Of course, I hope that we will have found the killer bugs
> > by that time, and that maintenance will only require following kernel API changes.
> 
> Just to make sure I'm understanding this correctly - does the v4 
> firmware drop compatibility for older cards, or is it just that Broadcom 
> dropped support in the driver at the same time as the firmware changed, 
> and the new firmware will still also drive the old cards?

We don't know.

It's likely that old cards still work with v4 firmware, but we don't know and
it has to be tested.

Care to do so?
-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
