From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: [PATCH] [001] dmfe : trivial/spelling fixes
Date: Thu, 8 Feb 2007 18:56:41 +0200
Message-ID: <200702081856.41456.maximlevitsky@gmail.com>
References: <189584.77434.qm@web38505.mail.mud.yahoo.com> <1170951913.3688.80.camel@localhost> <200702081853.22537.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:11274 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965715AbXBHQ7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 11:59:52 -0500
Received: by ug-out-1314.google.com with SMTP id 44so516549uga
        for <netdev@vger.kernel.org>; Thu, 08 Feb 2007 08:59:51 -0800 (PST)
In-Reply-To: <200702081853.22537.maximlevitsky@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 08 February 2007 18:53, you wrote:
> On Thursday 08 February 2007 18:25, you wrote:
> > On Wed, 2007-02-07 at 10:28 -0800, Levitsky Maxim wrote:
> > > --- linux-2.6.20-org/drivers/net/tulip/dmfe.c   2007-02-03
> > > 11:47:52.000000000 +0200 +++ linux-2.6.20-mod/drivers/net/tulip/dmfe.c
> > > 2007-02-07 14:41:29.000000000 +0200 @@ -722,7 +742,8 @@ static int
> > > dmfe_stop(struct DEVICE *dev)
> > >
> > >  #if 0
> > >         /* show statistic counter */
> > > -       printk(DRV_NAME ": FU:%lx EC:%lx LC:%lx NC:%lx LOC:%lx TXJT:%lx
> > > RESET:%lx RCR8:%lx FAL:%lx TT:%lx\n",
> > > +       printk(DRV_NAME ": FU:%lx EC:%lx LC:%lx NC:%lx LOC:%lx TXJT:%lx
> > > +               RESET:%lx RCR8:%lx FAL:%lx TT:%lx\n",
> >
> > Perhaps you should fix this introduced hanging close quote too
> >
> > something like:
> >
> > 	printk(DRV_NAME ": FU:%lx EC:%lx LC:%lx NC:%lx LOC:%lx TXJT:%lx "
> > 	       "RESET:%lx RCR8:%lx FAL:%lx TT:%lx\n",
> >
> > cheers,  Joe
>
> Yes I will review everyting from start , and send it again , (it is much
> easier to do using gmail ;-)
>
> cheers , Maxim Levitsky

forget to CC netdev@vger.kernel.org
