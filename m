From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Mobile Broadband Interface Model (MBIM) support?
Date: Fri, 24 May 2013 19:11:52 -0500
Message-ID: <1369440712.8000.11.camel@dcbw.foobar.com>
References: <20130524170915.GA15788@xanatos>
	 <20130524181051.GB15788@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	"Ismail, Rahman" <abdul.r.ismail-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Wallick, Stephanie S" <stephanie.s.wallick-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130524181051.GB15788@xanatos>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-05-24 at 11:10 -0700, Sarah Sharp wrote:
> Ccing Dan Williams, since Johannes Berg mentioned on IRC that Dan might
> know the status of MBIM support.

As Bjorn mentioned, libmbim just got a 1.0 release, and ModemManager
0.7.x (git master, basically) has support for MBIM devices via libmbim.
0.7.x will turn into an official 0.8 release Real Soon Now; it's already
built for Fedora 20, though we don't have libmbim capability in F20
quite yet.

Dan

> On Fri, May 24, 2013 at 10:09:15AM -0700, Sarah Sharp wrote:
> > Do we have support for the new extensions for USB communication devices
> > that use the Mobile Broadband Interface Model (MBIM) spec?
> > 
> > http://www.usb.org/developers/devclass_docs/MBIM10Errata1.zip
> > 
> > The spec was released pretty recently, which is why I'm asking on the
> > mailing lists, rather than digging around the kernel tree for a driver.
> > 
> > Sarah Sharp
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-usb" in
> > the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
