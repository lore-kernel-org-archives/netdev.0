From: Horms <horms@verge.net.au>
Subject: Re: IPVS Sysctl Variables
Date: Mon, 3 Jul 2006 10:14:07 +0900
Message-ID: <20060703011405.GD20593@verge.net.au>
References: <20060630061940.GA31956@verge.net.au> <20060630.142045.106433722.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, wensong@linux-vs.org, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:936 "EHLO koto.vergenet.net")
	by vger.kernel.org with ESMTP id S1750865AbWGCBni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jul 2006 21:43:38 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060630.142045.106433722.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 30, 2006 at 02:20:45PM -0700, David Miller wrote:
> From: Horms <horms@verge.net.au>
> Date: Fri, 30 Jun 2006 15:19:41 +0900
> 
> > there are quite a number of entries under /proc/sys/net/ipv4/vs,
> > I swear that they were documented in Documentation/networking/
> > at some stage, but perhaps I am dreaming.
> > 
> > In any case, if I clean up the information at the following URL (which a
> > probably complete list of what the options are and what they do, you don't
> > have to check if you don't want to), is it appropriate for inclusion in
> > Documentation/networking/, and if so, should it be in ip-sysctl.txt, or
> > elsewhere?
> > 
> > http://www.linuxvirtualserver.org/docs/sysctl.html
> 
> Good question, maybe ip-sysctl.txt is getting a bit crowded.
> I therefore wouldn't mind you putting this into networking/ipvs-sysctl.txt

Thanks, I will make that so.

-- 
Horms                                           
H: http://www.vergenet.net/~horms/          W: http://www.valinux.co.jp/en/

