From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] neighbour.c, pneigh_get_next() skips published entry
Date: Mon, 25 Sep 2006 17:34:16 -0700
Message-ID: <20060925173416.2a9c0c27.akpm@osdl.org>
References: <20060925164535.4245ee02.akpm@osdl.org>
	<20060925.164731.71091985.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jari.takkala@q9.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:61634 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751661AbWIZAeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 20:34:22 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060925.164731.71091985.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 25 Sep 2006 16:47:31 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@osdl.org>
> Date: Mon, 25 Sep 2006 16:45:35 -0700
> 
> > I've been sitting on this patch because afaik the problem which it purports
> > to fix remains unfixed.
> > 
> > Should I drop it??
> > 
> > Thanks.
> 
> Please drop it, the patch submitted didn't give us the feedback
> and test results we asked for which is necessary to pinpoint the
> true issue here.

Well that's why I hang onto such patches: so I can bug people about it
every few months.  Consider it the world's dumbest bug-tracking system.

But I have a feeling I'll get shouted at if I try it again with this one
(looks at the 18-month-old tulip-fix-for-64-bit-mips.patch), so yeah, I'll drop
it.  
