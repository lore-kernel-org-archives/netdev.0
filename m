From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: Fix code for spec changes of 2/7/2007
Date: Fri, 9 Feb 2007 20:17:36 +0100
Message-ID: <200702092017.36950.mb@bu3sch.de>
References: <45cca236.+lL/rsW3DbM3elnk%Larry.Finger@lwfinger.net> <45CCBB93.2040703@lwfinger.net> <45CCC5DF.8010001@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: Joseph Jezak <josejx-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <45CCC5DF.8010001-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 09 February 2007 20:05, Joseph Jezak wrote:
> > I'll agree to that as long as there is a clear indication of any differences between V3 and V4 firmware.
> 
> That's also part of the problem.  With the v4 driver, Broadcom 
> dropped support for a number of older BPHY devices (4301/4303 and 
> some 4306 revisions).  Do we still want to support those?  Should I 
> continue writing the specs for the uCode revision it's based on or 
> should I combine them?

If it's easily possible, please try to combine the old stuff
with the new v4 specs.
I think it's basically only dropped if() branches, right?

-- 
Greetings Michael.
-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
