From: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2.6] SoftMAC : fix duplicate display of channel in scan
Date: Thu, 12 Jul 2007 09:49:18 -0700
Message-ID: <20070712164918.GC13445@bougret.hpl.hp.com>
References: <20070710184155.GA6955@bougret.hpl.hp.com> <4693DD18.1010905@lwfinger.net> <1184211018.9446.0.camel@localhost.localdomain> <20070712163440.GA13445@bougret.hpl.hp.com> <46965977.7020807@lwfinger.net>
Reply-To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46965977.7020807-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 12, 2007 at 11:40:23AM -0500, Larry Finger wrote:
> Jean Tourrilhes wrote:
> >
> >	Well, I actually like forcing driver to use frequency, because
> >that's an absolute physical measure and contains more meaning.
> 
> Yes, but it is easier to keep a channel number in your head than a 
> frequency.

	That's why iwlist display both in 'iwlist freq' and 'iwlist scan'.

> Larry

	Jean
