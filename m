From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH] ucc_geth: add support for netpoll
Date: Thu, 1 Nov 2007 13:05:39 +0300
Message-ID: <20071101100539.GA24088@localhost.localdomain>
References: <20071011124842.GB13963@localhost.localdomain> <4723389F.7010109@ru.mvista.com> <20071027143731.GA2616@zarina> <989B956029373F45A0B8AF0297081890019B61BF@zch01exm26.fsl.freescale.net> <20071029121744.GA20372@localhost.localdomain> <20071031215903.GA1287@zarina> <989B956029373F45A0B8AF0297081890019B642A@zch01exm26.fsl.freescale.net>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Li Yang-r58472 <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:38720 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753753AbXKAKHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 06:07:23 -0400
Content-Disposition: inline
In-Reply-To: <989B956029373F45A0B8AF0297081890019B642A@zch01exm26.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 01, 2007 at 10:33:24AM +0800, Li Yang-r58472 wrote:
> > -----Original Message-----
> > From: Anton Vorontsov [mailto:cbou@mail.ru] 
> > Sent: Thursday, November 01, 2007 5:59 AM
> > To: Li Yang-r58472
> > Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; 
> > linuxppc-dev@ozlabs.org
> > Subject: Re: [PATCH] ucc_geth: add support for netpoll
> > 
> > On Mon, Oct 29, 2007 at 03:17:44PM +0300, Anton Vorontsov wrote:
> > [...]
> > > > Oops.  The original patch happened to hit the Junk mail box. :(
> > > 
> > > That one as well? http://lkml.org/lkml/2007/10/11/128
> > > 
> > > > I think
> > > > the patch is good to merge after the cosmetic change.  I 
> > can do it 
> > > > in next pull request to Jeff.
> > > 
> > > Ok, great. Thanks.
> > 
> > I'm wondering if you missed that email again. Maybe your mail 
> > client/server doing weird things with emails from @ru.mvista.com?
> 
> No.  I have explicitly add you to the whitelist. :)

Hehe, thanks. ;-)

> Please be patient,
> isn't this patch a new feature which can only be integrated in the merge
> window?

Sure it is. I didn't mean to "hurry up" you, of course not.

Just wondered if you've solved issues with getting my emails. Such
wonders are quite normal if there was a precedent lately. ;-)


Sorry for troubling you,

-- 
Anton Vorontsov
email: cbou@mail.ru
backup email: ya-cbou@yandex.ru
irc://irc.freenode.net/bd2
