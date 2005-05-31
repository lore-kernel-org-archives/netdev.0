From: Phil Oester <kernel@linuxace.com>
Subject: Re: 2.6.12-rcx networking oops
Date: Tue, 31 May 2005 16:34:35 -0700
Message-ID: <20050531233435.GA17397@linuxace.com>
References: <20050531224012.GA16789@linuxace.com> <20050531161220.4af50a69.akpm@osdl.org> <20050531232326.GA17289@linuxace.com> <20050531162837.4a110b29.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, herbert@gondor.apana.org.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050531162837.4a110b29.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 31, 2005 at 04:28:37PM -0700, Andrew Morton wrote:
> hm, OK.  So I assume the machine has recently been running 2.6.10.  So it's
> unlikely to be a hardware problem.

It's running 2.6.10 as we speak -- I typically reboot it at night into 
2.6.12-rc and between 8-10am the next day it panics itself back into
2.6.10.

> > > Have you tried CONFIG_DEBUG_SLAB and/or CONFIG_DEBUG_PAGEALLOC?
> > 
> > No - do you think it would reveal anything given the above?
> 
> It might catch the failure at an earlier stage.

I'll try it out tomorrow.

Phil
