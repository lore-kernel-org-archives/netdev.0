From: maximilian attems <max@stro.at>
Subject: Re: b44 compile failure
Date: Wed, 30 Jan 2008 19:20:03 +0100
Message-ID: <20080130182003.GH12407@stro.at>
References: <20080130105926.GC24152@stro.at> <20080130162157.GC3317@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: zambrano@broadcom.com, netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:38704 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbYA3SUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 13:20:09 -0500
Content-Disposition: inline
In-Reply-To: <20080130162157.GC3317@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Jan 2008, John W. Linville wrote:

> On Wed, Jan 30, 2008 at 11:59:26AM +0100, maximilian attems wrote:
> >  drivers/net/b44.c: In function 'b44_remove_one':
> >  drivers/net/b44.c:2231: error: implicit declaration of function 'ssb_pcihost_set_power_state'
> > 
> >  compiles fine on 64 bit x86, but not on 32, see log:
> >  http://stats.buildserver.net/fetch.php?&pkg=linux-2.6&ver=2.6.24-trunk1%7Esnapshot.10272&arch=i386&stamp=1201665377&file=log&as=raw
> 
> It seems to build fine on my i686 box.  What dtree are you using?
> And what is your .config?  Is CONFIG_SSB enabled?

don't see any CONFIG_SSB above.

strange can't reprodcue neither, so forget for now.

thanks
 
