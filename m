From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: bonding...
Date: Thu, 3 Mar 2011 16:12:50 -0500
Message-ID: <20110303211250.GQ11864@gospo.rdu.redhat.com>
References: <20110303114539.GB5146@hmsreliant.think-freely.org> <20110303160404.GO11864@gospo.rdu.redhat.com> <6286.1299173065@death> <20110303.123032.15242274.davem@davemloft.net> <13010.1299184990@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, andy@greyhouse.net,
	nhorman@tuxdriver.com, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61385 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751805Ab1CCVM7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 16:12:59 -0500
Content-Disposition: inline
In-Reply-To: <13010.1299184990@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 03, 2011 at 12:43:10PM -0800, Jay Vosburgh wrote:
> David Miller <davem@davemloft.net> wrote:
> 
> >From: Jay Vosburgh <fubar@us.ibm.com>
> >Date: Thu, 03 Mar 2011 09:24:25 -0800
> >
> >> 	My main problem keeping up at the moment is another demand on my
> >> time that should run its course in a couple of weeks.  My time for
> >> community activity is somewhat limited until then.
> >
> >Someone needs to exist who can keep things going when you are too
> >busy.  Unless you're like me and never take a day off, you need
> >at least one co-maintainer if your subsystem has lots of daily
> >activity as bonding now does.
> 
> 	Agreed.  If Andy is amenable, we can make it official:
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 0d83e58..6402703 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -1467,6 +1467,7 @@ F:	include/net/bluetooth/
>  
>  BONDING DRIVER
>  M:	Jay Vosburgh <fubar@us.ibm.com>
> +M:	Andy Gospodarek <andy@greyhouse.net>
>  L:	netdev@vger.kernel.org
>  W:	http://sourceforge.net/projects/bonding/
>  S:	Supported
> 
> 

Acked-by: Andy Gospodarek <andy@greyhouse.net>

