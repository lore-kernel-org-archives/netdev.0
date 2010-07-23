From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Linux 2.6.35-rc6
Date: Fri, 23 Jul 2010 22:16:15 +0200
Message-ID: <201007232216.16044.rjw@sisk.pl>
References: <AANLkTinJe-oHpgQqnTPQyKUtmKhg2oUJmylkBPALuzGh@mail.gmail.com> <20100723112142.f698394e.sfr@canb.auug.org.au> <20100723122213.GA689@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Michal Marek <mmarek@suse.cz>,
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:53859 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752051Ab0GWUSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jul 2010 16:18:20 -0400
In-Reply-To: <20100723122213.GA689@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, July 23, 2010, Greg KH wrote:
> On Fri, Jul 23, 2010 at 11:21:42AM +1000, Stephen Rothwell wrote:
> > Hi Linus,
> > 
> > On Thu, 22 Jul 2010 12:26:13 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:
> > >
> >  I actually hope/think that this is going to be the last -rc. Things
> > > have been pretty quiet, and while this -rc has more commits than -rc5
> > > had, it's not by a large amount, nor does it look scary to me. So
> > > there doesn't seem to be any point in dragging out the release any
> > > more, unless we find something new that calls for it.
> > 
> > I have no idea how important this stuff is, but I still have the
> > following in linux-next that are (in theory) destined for v2.6.35:
> 
> <snip>
> 
> Yes, there are a few minor USB patches in my tree (minor bugfixes and
> new device ids) that I wanted to send to you, but no need to hold up a
> .35 release.
> 
> We're still working on the network namespace sysfs issues, but if that
> option is disabled, all works fine.  I have 3 tiny patches to work to
> resolve that problem in my tree, I can send them to you tonight if you
> want.
> 
> But even there, nothing that should hold up .35 from release.

There are a few things, including regression fixes, in the ACPI land AFAICS.

Rafael

