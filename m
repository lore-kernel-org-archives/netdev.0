From: CAI Qian <caiqian@redhat.com>
Subject: request to queue patches for stable
Date: Mon, 10 Dec 2012 21:03:15 -0500 (EST)
Message-ID: <1907800187.6214689.1355191395335.JavaMail.root@redhat.com>
References: <20121206.222321.485936471142281291.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:38838 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751849Ab2LKCDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 21:03:15 -0500
Received: from zmail14.collab.prod.int.phx2.redhat.com (zmail14.collab.prod.int.phx2.redhat.com [10.5.83.16])
	by mx4-phx2.redhat.com (8.13.8/8.13.8) with ESMTP id qBB23FZD013880
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2012 21:03:15 -0500
In-Reply-To: <20121206.222321.485936471142281291.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> From: "David Miller" <davem@davemloft.net>
> To: caiqian@redhat.com
> Cc: greg@kroah.com, stable@vger.kernel.org, mbizon@freebox.fr, ja@ssi.bg
> Sent: Friday, December 7, 2012 11:23:21 AM
> Subject: Re: [PATCH] ipv4: do not cache looped multicasts
> 
> From: CAI Qian <caiqian@redhat.com>
> Date: Thu, 6 Dec 2012 21:56:35 -0500 (EST)
> 
> > OK, I have a few network patches in the queue that looks applicable
> > to
> > the stable as well. I think I'll send them out here too to seek
> > their
> > ACKs. David, please let me know if I should stop doing this.
> 
> Please stop doing this.
> 
> If you want networking patches to reach stable, first
> consult:
> 
> http://patchwork.ozlabs.org/bundle/davem/stable/
> 
> to see if the patch you want isn't queued up already.
> 
> If it is not, ask me to queue it up on netdev@vger.kernel.org
> 
> But note that I like to let networking patches "cook" upstream
> in Linus's tree for a certain amount of time before I submit
> them to -stable.  There can be up to even a week or two.
Dave, the following patches looks applicable for the stable
releases. Please queue them up if you agree.

0e376bd0b791ac6ac6bdb051492df0769c840848 (for 3.0.x, 3.4.x and 3.6.x)
e196c0e579902f42cf72414461fb034e5a1ffbf7 (for 3.0.x, 3.4.x and 3.6.x)
6e51fe7572590d8d86e93b547fab6693d305fd0d (for 3.0.x, 3.4.x and 3.6.x)
e1a676424c290b1c8d757e3860170ac7ecd89af4 (for 3.6.x)
636174219b52b5a8bc51bc23bbcba97cd30a65e3 (for 3.6.x)

CAI Qian
