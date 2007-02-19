From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Subject:  [PATCH 2.6.20 004/005] dmfe: Add support for suspend/resume
Date: Mon, 19 Feb 2007 12:41:17 +0100
Message-ID: <20070219114117.GB19184@elf.ucw.cz>
References: <200702152253.53680.maximlevitsky@gmail.com> <200702180029.03651.maximlevitsky@gmail.com> <20070217225215.GE14222@elf.ucw.cz> <200702181543.53296.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@kernel.org, linux-kernel@vger.kernel.org
To: Maxim <maximlevitsky@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932119AbXBSLll@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200702181543.53296.maximlevitsky@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> > and add space before */.
> > 
> > Congratulation, you passed coding-style-police-check ;-).
> > 									Pavel
> > 
> 
> Hello,
> 	Thanks for reply, I just want to ask one question:
> 
> 	Those patches are now merged in -mm, and I noticed that Andrew Morton after applying them did fix my bad coding style and check for CONFIG_PM=n that I didn't include
> 	Now should I resend two last patches or not ?

Well,  i guess you should wait for next -mm tree, and if you see some
problem you fixed and akpm did not, fix it and send a incremental
patch...

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
