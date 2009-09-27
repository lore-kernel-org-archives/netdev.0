From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 1/3] lib/vsprintf.c: Add %pU - ptr to a UUID/GUID
Date: Sun, 27 Sep 2009 13:53:48 -0700
Message-ID: <20090927205348.GA32464@kroah.com>
References: <cover.1254030722.git.joe@perches.com>
 <1507728e0ea3deafa71c481d508a6e9765c92221.1254030722.git.joe@perches.com>
 <200909271245.34000.ioe-lkml@rameria.de>
 <1254078046.28232.183.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Oeser <ioe-lkml@rameria.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752711AbZI0U7S@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1254078046.28232.183.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 27, 2009 at 12:00:46PM -0700, Joe Perches wrote:
> On Sun, 2009-09-27 at 12:45 +0200, Ingo Oeser wrote:
> > Hi Joe,
> 
> Hello Ingo.
> 
> > On Sunday 27 September 2009, Joe Perches wrote:
> > > UUID/GUIDs are somewhat common in kernel source.
> > > Standardize the printed style of UUID/GUIDs by using
> > > another extension to %p.
> > > %pU:    01020304:0506:0708:090a:0b0c0d0e0f10
> > > %pUr:   04030201:0605:0807:0a09:0b0c0d0e0f10
> > Code does "01020304-0506-0708-090a-0b0c0d0e0f10".
> > This is not, what commit promises. Please change the commit message!
> 
> True enough, that can change, no worries.
> 
> Does anyone have comments like:
> 
> 1 what a stupid idea
> 2 how unnecessary
> 3 meh
> 4 bloat alert! linux is supposed to be lean
> 5 ok idea, bad implementation
> 6 sure, why not

Sure, why not :)
