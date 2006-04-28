From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 23:52:40 +0400
Message-ID: <20060428195238.GA21294@2ka.mipt.ru>
References: <20060428172932.GB16916@2ka.mipt.ru> <20060428104118.6a056a59@localhost.localdomain> <20060428175538.GA13898@2ka.mipt.ru> <20060428.121636.54294183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: shemminger@osdl.org, caitlinb@broadcom.com, kelly@au1.ibm.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:58848 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751449AbWD1Txz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 15:53:55 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060428.121636.54294183.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 28, 2006 at 12:16:36PM -0700, David S. Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Fri, 28 Apr 2006 21:55:39 +0400
> 
> > On Fri, Apr 28, 2006 at 10:41:18AM -0700, Stephen Hemminger (shemminger@osdl.org) wrote:
> > > Second, introducing
> > > kevents, seems unnecessary and hasn't been accepted in the mainline.
> > 
> > kevent was never sent to lkml@ although it showed over 40% win over epoll for
> > test web server. Sending it to lkml@ is just jumping into ... not into
> > technical world, so I posted it first here, but without much attention
> > though.
> 
> Frankly I found kevents to be a very strong idea.

Glad to hear this.
I probably should resend patches netdev@ and (mar my karma) send it to
lkml@...?

-- 
	Evgeniy Polyakov
