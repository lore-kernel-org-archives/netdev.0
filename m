From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [git patches] net driver updates
Date: Sat, 20 May 2006 10:36:33 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0605201035510.10823@g5.osdl.org>
References: <20060520042856.GA7218@havoc.gtf.org> <20060520092033.7d404315.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:10948 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751449AbWETRgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 May 2006 13:36:38 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060520092033.7d404315.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 20 May 2006, Andrew Morton wrote:
> Jeff Garzik <jeff@garzik.org> wrote:
> >
> > Andrew Morton:
> >        revert "forcedeth: fix multi irq issues"
> 
> Manfred just found the fix for this, so we should no longer need to revert.

Hmm. I already pulled. I guess we can revert the revert and apply 
Manfreds fix. Jeff?

		Linus
