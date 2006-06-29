From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netchannels: progress report.
Date: Thu, 29 Jun 2006 22:15:30 +0400
Message-ID: <20060629181529.GA2336@2ka.mipt.ru>
References: <20060608171555.GA10273@2ka.mipt.ru> <20060613173321.GA648@2ka.mipt.ru> <20060629093801.GA6049@2ka.mipt.ru> <Pine.LNX.4.64.0606291318420.24645@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:43401 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751239AbWF2SPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 14:15:30 -0400
To: James Morris <jmorris@namei.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0606291318420.24645@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 29, 2006 at 01:19:29PM -0400, James Morris (jmorris@namei.org) wrote:
> On Thu, 29 Jun 2006, Evgeniy Polyakov wrote:
> 
> > +#define __NR_netchannel_control	279
> > +__SYSCALL(__NR_vmsplice, sys_netchannel_control)
> 
> This looks wrong.
 
Ugh, it's my hand merge for x86_64.
Thank you for spotting this, James.
 
> -- 
> James Morris
> <jmorris@namei.org>

-- 
	Evgeniy Polyakov
