From: maximilian attems <janitor@sternwelten.at>
Subject: Re: sis900 oops on resume
Date: Thu, 18 Nov 2004 03:14:25 +0100
Message-ID: <20041118021425.GA2128@stro.at>
References: <20041117182403.GC2252@stro.at> <20041117201008.GA11439@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Daniele Venzano <webvenza@libero.it>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pavel Machek <pavel@ucw.cz>
Content-Disposition: inline
In-Reply-To: <20041117201008.GA11439@elf.ucw.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 17 Nov 2004, Pavel Machek wrote:

> Hi!
> 
> > happens since the use of guessnet,
> > guessnet is based on divine and sends arp requests to network.
> > network was down after the oops, but beside resume system worked.
> 
> And where do you see the oops? Irq 10 does not work, that's only
> backtrace. Fix the sis900 driver...
> 
> 							Pavel
 
ok, i'm not that familiar with suspend pathes,
what's going wrong in sis900_resume() or sis900_suspend()?

maks
