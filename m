From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [-mm patch] drivers/net/ni5010.c: fix compile error
Date: Thu, 22 Jun 2006 10:45:21 +0200
Message-ID: <20060622084521.GX9111@stusta.de>
References: <20060621034857.35cfe36f.akpm@osdl.org> <20060621151057.GF9111@stusta.de> <20060622081316.GA24980@rhlx01.fht-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:61198 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S1751771AbWFVIpW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 04:45:22 -0400
To: Andreas Mohr <andi@rhlx01.fht-esslingen.de>
Content-Disposition: inline
In-Reply-To: <20060622081316.GA24980@rhlx01.fht-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 22, 2006 at 10:13:16AM +0200, Andreas Mohr wrote:
> Hi,
> 
> On Wed, Jun 21, 2006 at 05:10:57PM +0200, Adrian Bunk wrote:
> > On Wed, Jun 21, 2006 at 03:48:57AM -0700, Andrew Morton wrote:
> > >...
> > > Changes since 2.6.17-rc6-mm2:
> > >...
> > > +ni5010-netcard-cleanup.patch
> > > 
> > >  netdev cleanup
> > >...
> > 
> > This patch fixes the following compile error with CONFIG_NI5010=y:
> 
> Doh, thanks!
> (that should teach me to do non-module runs, too)

And change the driver to no longer use Space.c?  ;-)

> Andreas Mohr

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

