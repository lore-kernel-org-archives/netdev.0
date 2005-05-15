From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [RFC: 2.6 patch] make MII no longer user visible
Date: Sun, 15 May 2005 14:12:22 +0200
Message-ID: <20050515121222.GR16549@stusta.de>
References: <20050513035257.GC3603@stusta.de> <4284DD16.8090405@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262819AbVEOMMe@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4284DD16.8090405@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 13, 2005 at 01:00:06PM -0400, Jeff Garzik wrote:
> Adrian Bunk wrote:
> >MII is a classical example of a helper option no user should ever see.
> 
> Incorrect.
> 
> It's the classic example of an option that distributors may want to 
> build as a module, even if no shipped modules need it, to enable net 
> driver development and use in their kernel.

Every distibutor will have more than one net driver select'ing MII 
enabled.

And if you are doing net driver development, you can always enable it in 
your kernel.

> 	Jeff

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
