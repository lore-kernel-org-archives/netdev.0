From: Pavel Machek <pavel@suse.cz>
Subject: Re: ipw2100 wireless driver
Date: Wed, 14 Jul 2004 13:55:23 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040714115523.GC2269@elf.ucw.cz>
References: <20040714114135.GA25175@elf.ucw.cz> <Pine.LNX.4.60.0407141947270.27995@boston.corp.fedex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, kernel list <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S267253AbUGNM1R@vger.kernel.org>
To: Jeff Chua <jeffchua@silk.corp.fedex.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.60.0407141947270.27995@boston.corp.fedex.com>
List-Id: netdev.vger.kernel.org

Hi!

> >What is the status of ipw2100? Is there chance that it would be pushed
> >into mainline?
> >
> >I have few problems with that:
> >
> >* it will not compile with gcc-2.95. Attached patch fixes one problem
> >but more remain.
> 
> I've given up hope on that. Don't think it'll ever compile on 2.95. I'm 
> using ndiswrapper and it works nicely.

No, I think that can be fixed... I'll rather fix ipw2100 than use
ndiswrapper.

								Pavel
-- 
People were complaining that M$ turns users into beta-testers...
...jr ghea gurz vagb qrirybcref, naq gurl frrz gb yvxr vg gung jnl!
