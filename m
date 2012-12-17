From: CAI Qian <caiqian@redhat.com>
Subject: Re: request to queue patches for stable
Date: Sun, 16 Dec 2012 20:05:22 -0500 (EST)
Message-ID: <1687740004.1489340.1355706322262.JavaMail.root@redhat.com>
References: <20121214.153825.1087482329989146130.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:38099 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397Ab2LQBFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2012 20:05:24 -0500
In-Reply-To: <20121214.153825.1087482329989146130.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> From: "David Miller" <davem@davemloft.net>
> To: caiqian@redhat.com
> Cc: netdev@vger.kernel.org
> Sent: Saturday, December 15, 2012 4:38:25 AM
> Subject: Re: request to queue patches for stable
> 
> From: CAI Qian <caiqian@redhat.com>
> Date: Mon, 10 Dec 2012 21:03:15 -0500 (EST)
> 
> > 
> > 
> > ----- Original Message -----
> >> From: "David Miller" <davem@davemloft.net>
> >> To: caiqian@redhat.com
> >> Cc: greg@kroah.com, stable@vger.kernel.org, mbizon@freebox.fr,
> >> ja@ssi.bg
> >> Sent: Friday, December 7, 2012 11:23:21 AM
> >> Subject: Re: [PATCH] ipv4: do not cache looped multicasts
> >> 
> >> From: CAI Qian <caiqian@redhat.com>
> >> Date: Thu, 6 Dec 2012 21:56:35 -0500 (EST)
> >> 
> >> > OK, I have a few network patches in the queue that looks
> >> > applicable
> >> > to
> >> > the stable as well. I think I'll send them out here too to seek
> >> > their
> >> > ACKs. David, please let me know if I should stop doing this.
> >> 
> >> Please stop doing this.
> >> 
> >> If you want networking patches to reach stable, first
> >> consult:
> >> 
> >> http://patchwork.ozlabs.org/bundle/davem/stable/
> >> 
> >> to see if the patch you want isn't queued up already.
> >> 
> >> If it is not, ask me to queue it up on netdev@vger.kernel.org
> >> 
> >> But note that I like to let networking patches "cook" upstream
> >> in Linus's tree for a certain amount of time before I submit
> >> them to -stable.  There can be up to even a week or two.
> > Dave, the following patches looks applicable for the stable
> > releases. Please queue them up if you agree.
> > 
> > 0e376bd0b791ac6ac6bdb051492df0769c840848 (for 3.0.x, 3.4.x and
> > 3.6.x)
> > e196c0e579902f42cf72414461fb034e5a1ffbf7 (for 3.0.x, 3.4.x and
> > 3.6.x)
> > 6e51fe7572590d8d86e93b547fab6693d305fd0d (for 3.0.x, 3.4.x and
> > 3.6.x)
> > e1a676424c290b1c8d757e3860170ac7ecd89af4 (for 3.6.x)
> > 636174219b52b5a8bc51bc23bbcba97cd30a65e3 (for 3.6.x)
> 
> What is the point of my publishing the pending networking -stable
> queue if you're not even going to check it?  Those last two patches
> were already queued up.
Dave, Yes, I did check the link you gave to me. However, it was empty
(no patch there) when emailing you, so I thought none of those been
queued up yet. It is also empty now. If I clicked the "patches" link,
it pointed me to http://patchwork.ozlabs.org/project/netdev/list/
which it has patches but I believe it is not for the stable. Please
let me know if I am missing anything.
> 
> Furthermore, it is erroneous to suggest the -ENOMEM SCTP fix without
> the memory leak fix that happens in the commit right before it.
Thanks for the reviewing.
> 
> I've queued things up appropriately, but I really don't appreciate
> how you've handled this at all.  It makes a lot more work for me than
> necessary.
OK, thanks for letting me know.

CAI Qian
> 
> 
