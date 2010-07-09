From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v4 1/9] atm: propagate signal changes via notifier
Date: Fri, 9 Jul 2010 21:22:33 +0900
Message-ID: <20100709122233.GB18487@verge.net.au>
References: <1278578095-25324-1-git-send-email-karl@hiramoto.org>
 <1278578095-25324-2-git-send-email-karl@hiramoto.org>
 <20100708.214745.48520104.davem@davemloft.net>
 <20100709071610.42473d6c@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, karl@hiramoto.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:41974 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755750Ab0GIMWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 08:22:37 -0400
Content-Disposition: inline
In-Reply-To: <20100709071610.42473d6c@thirdoffive.cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 09, 2010 at 07:16:10AM -0400, chas williams - CONTRACTOR wrote:
> On Thu, 08 Jul 2010 21:47:45 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Karl Hiramoto <karl@hiramoto.org>
> > Date: Thu,  8 Jul 2010 10:34:47 +0200
> > 
> > /* Like
> >  * this.
> >  */
> > 
> > not:
> > 
> > /*
> >  * Like
> >  * this.
> >  */
> > 
> > Honestly, I don't know how I can be more clear about this :-)
> 
> this is somewhat contrary to the suggested multi-line format given in
> Documentation/CodingStyle:
> 
> 
> The preferred style for long (multi-line) comments is:
> 
>         /*
>          * This is the preferred style for multi-line
>          * comments in the Linux kernel source code.
>          * Please use it consistently.
>          *
>          * Description:  A column of asterisks on the left side,
>          * with beginning and ending almost-blank lines.
>          */

This is a topic that seems to come up every now and again.
I think that the reality of the situation is that there
are several acceptable styles and some maintainers prefer
one over the other, some more strongly than others.

So I think that documentation is slightly misleading
though it is certainly true for many maintainers.

