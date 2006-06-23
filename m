From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 0/2][RFC] Network Event Notifier Mechanism
Date: Fri, 23 Jun 2006 15:12:37 -0500
Message-ID: <1151093557.7808.71.camel@stevo-desktop>
References: <20060622.155805.35017169.davem@davemloft.net>
	 <1151024186.5099.46.camel@jzny2> <1151069083.7808.19.camel@stevo-desktop>
	 <20060623.125758.30182159.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org, caitlinb@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:41838 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1752014AbWFWUMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 16:12:39 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060623.125758.30182159.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-06-23 at 12:57 -0700, David Miller wrote:
> From: Steve Wise <swise@opengridcomputing.com>
> Date: Fri, 23 Jun 2006 08:24:43 -0500
> 
> > On Thu, 2006-06-22 at 20:56 -0400, jamal wrote:
> > > On Thu, 2006-22-06 at 15:58 -0700, David Miller wrote:
> > > 
> > > > Anyways, we can create normal notifiers for neighbour and route
> > > > events just like we have for network device stuff.
> > > >
> > 
> > So did you agree with a new notifier head for these events as in my
> > original patch?  Or do you think I should add these to the netdev
> > notifier?  
> 
> Pretty much.  I may not agree with the details of your implementation.
> 
> So let's start by you doing a repost of the first patch and let's
> review that, ok?

Ok.  Stay tuned.

Steve.





