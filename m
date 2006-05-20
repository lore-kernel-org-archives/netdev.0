From: Andrew Morton <akpm@osdl.org>
Subject: Re: [git patches] net driver updates
Date: Sat, 20 May 2006 10:55:47 -0700
Message-ID: <20060520105547.220f2bea.akpm@osdl.org>
References: <20060520042856.GA7218@havoc.gtf.org>
	<20060520092033.7d404315.akpm@osdl.org>
	<Pine.LNX.4.64.0605201035510.10823@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:711 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751467AbWETR4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 May 2006 13:56:03 -0400
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0605201035510.10823@g5.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds <torvalds@osdl.org> wrote:
>
> 
> 
> On Sat, 20 May 2006, Andrew Morton wrote:
> > Jeff Garzik <jeff@garzik.org> wrote:
> > >
> > > Andrew Morton:
> > >        revert "forcedeth: fix multi irq issues"
> > 
> > Manfred just found the fix for this, so we should no longer need to revert.
> 
> Hmm. I already pulled. I guess we can revert the revert and apply 
> Manfreds fix. Jeff?
> 

I can cook up the necessary pieces.
