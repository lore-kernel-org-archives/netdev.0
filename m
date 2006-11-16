From: Greg KH <gregkh@suse.de>
Subject: Re: 2.6.19-rc6: known regressions
Date: Thu, 16 Nov 2006 13:43:59 -0800
Message-ID: <20061116214359.GA32690@suse.de>
References: <Pine.LNX.4.64.0611152008450.3349@woody.osdl.org> <20061116213717.GJ31879@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ray Lee <ray-lk@madrabbit.org>, Michael Buesch <mb@bu3sch.de>,
	Larry Finger <Larry.Finger@lwfinger.net>, st3@riseup.net,
	linville@tuxdriver.com, netdev@vger.kernel.org,
	David Brownell <david-b@pacbell.net>,
	Len Brown <len.brown@intel.com>,
	Alexey Starikovskiy <alexey.y.starikovskiy@linux.intel.com>,
	linux-acpi@vger.kernel.org, Ernst Herzberg <earny@net4u.de>,
	Ingo Molnar <mingo@elte.hu>, Andre Noll <maan@systemlinux.org>,
	Andi Kleen <ak@suse.de>, discuss@x86-64.org,
	Prakash Punnoor <prakash@punnoor.de>, phil.el@wanadoo.fr,
	oprofile-list@lists.sf.net, Dennis Stosberg <dennis@stosberg.net>,
	ecashin@coraid.com, Andrey Borzenkov <arvidjaar@mail.ru>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-usb-devel@lists.sourceforge.net
Return-path: <linux-acpi-owner@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20061116213717.GJ31879@stusta.de>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 16, 2006 at 10:37:18PM +0100, Adrian Bunk wrote:
> Subject    : aoe: Add forgotten NULL at end of attribute list in aoeblk.c
> References : http://lkml.org/lkml/2006/11/13/26
> Submitter  : Dennis Stosberg <dennis@stosberg.net>
> Caused-By  : Greg Kroah-Hartman <gregkh@suse.de>
>              commit 4ca5224f3ea4779054d96e885ca9b3980801ce13
> Handled-By : Dennis Stosberg <dennis@stosberg.net>
> Patch      : http://lkml.org/lkml/2006/11/13/26
> Status     : patch available
> 
> 
> Subject    : can't disable OHCI wakeup via sysfs
> References : http://lkml.org/lkml/2006/11/11/33
> Submitter  : Andrey Borzenkov <arvidjaar@mail.ru>
> Handled-By : Alan Stern <stern@rowland.harvard.edu>
> Patch      : http://lkml.org/lkml/2006/11/13/261
> Status     : patch available

I'll be sending Linus both of these patches later today.

thanks,

greg k-h
