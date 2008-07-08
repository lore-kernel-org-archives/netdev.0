From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH] irda: driver for Freescale FIRI controller
Date: Tue, 8 Jul 2008 19:44:21 +0400
Message-ID: <20080708154421.GA4471@polina.dev.rtsoft.ru>
References: <20080604154510.GA31162@polina.dev.rtsoft.ru> <20080611222524.GA6710@sortiz.org>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Zhang Wei <Wei.Zhang@freescale.com>,
	Timur Tabi <timur@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:34430 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753892AbYGHPoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 11:44:25 -0400
Content-Disposition: inline
In-Reply-To: <20080611222524.GA6710@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 12, 2008 at 12:25:25AM +0200, Samuel Ortiz wrote:
> Hi Anton,
> 
> On Wed, Jun 04, 2008 at 07:45:10PM +0400, Anton Vorontsov wrote:
> > From: Zhang Wei <wei.zhang@freescale.com>
> > 
> > The driver supports SIR, MIR, FIR modes and maximum 4000000bps rate.
> > 
> > Signed-off-by: Zhang Wei <wei.zhang@freescale.com>
> > [AV: few small fixes, plus had made platform ops passing via node->data
> >      to avoid #ifdef stuff in the fsl_soc (think DIU). ]
> > Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> Some comments below:

Sorry, it took me so long to answer. :-/

Much thanks for the comments, will fix them all. That is, your review
work isn't in vain, I'm much appreciated it.

Thanks again,

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
