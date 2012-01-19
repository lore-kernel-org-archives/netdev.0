From: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: iwlwifi worse than ever in current git.
Date: Thu, 19 Jan 2012 17:04:11 -0500
Message-ID: <20120119220410.GA11980@redhat.com>
References: <20120110184917.GA26973@redhat.com>
 <1326221614.5067.6.camel@dcbw.foobar.com>
 <0BA3FCBA62E2DC44AF3030971E174FB3063085@HASMSX103.ger.corp.intel.com>
 <20120111014243.GA22066@redhat.com>
 <0BA3FCBA62E2DC44AF3030971E174FB306429E@HASMSX103.ger.corp.intel.com>
 <20120111195055.GA5140@redhat.com>
 <0BA3FCBA62E2DC44AF3030971E174FB3064AF5@HASMSX103.ger.corp.intel.com>
 <CANUX_P3UHz-Pr_M1H5pAbmKDY70es7nxkWSDGXG6-hvrPAMCJw@mail.gmail.com>
 <20120119182955.GA1630@redhat.com>
 <0BA3FCBA62E2DC44AF3030971E174FB3079A3F@HASMSX103.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Guy, Wey-Yi W" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Linux Wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <0BA3FCBA62E2DC44AF3030971E174FB3079A3F-yLYCJVCiOGwLt2AQoY/u9bfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 19, 2012 at 08:38:35PM +0000, Grumbach, Emmanuel wrote:
 > > 
 > > >
 > > > On Thu, Jan 19, 2012 at 08:47:28AM +0200, Emmanuel Grumbach wrote:
 > > >  > Ok, I finally had a change to take a closer look at this. Please run
 > > >  > with debug=0xC0000000.
 > > >  >
 > > >  > This will be noisy, but I guess we have no choice...
 > > >  > I will be travelling next week, so...
 > > >
 > > > Ah. Got it. I had to do a large download (a kernel tarball was enough) to
 > > > trigger it.
 > > > Log is at http://davej.fedorapeople.org/iwl-debug.txt
 > > >
 > > > The download began at around 13:17 in the log.
 > > > It hung shortly afterwards.
 > > >
 > > > 	Dave
 > > 
 > > Thanks for that one. Really helpful. I need to send you a patch to get a
 > > little more data. I don't know when I will be able to do it though.
 > 
 > Can you please retry with the patch attached ?

Hung again.

http://davej.fedorapeople.org/iwl-debug2.txt

	Dave

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
