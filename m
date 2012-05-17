From: Willy Tarreau <w@1wt.eu>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO packets'
Date: Fri, 18 May 2012 00:30:28 +0200
Message-ID: <20120517223028.GV14498@1wt.eu>
References: <20120517221641.GS14498@1wt.eu> <1337293351.3403.67.camel@edumazet-glaptop> <20120517222431.GT14498@1wt.eu> <20120517.182545.91312407467980757.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2360 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030224Ab2EQWac (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 18:30:32 -0400
Content-Disposition: inline
In-Reply-To: <20120517.182545.91312407467980757.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 17, 2012 at 06:25:45PM -0400, David Miller wrote:
> From: Willy Tarreau <w@1wt.eu>
> Date: Fri, 18 May 2012 00:24:31 +0200
> 
> > On Fri, May 18, 2012 at 12:22:31AM +0200, Eric Dumazet wrote:
> >> Hmm... I believe I prefer your prior patch ( the one I Acked)
> > 
> > I too, less changes are better :-)
> 
> And I think that's the one I'm going to apply after I audit this
> code a little bit myself.
> 
> Thanks!

Sorry for the double mail, I didn't know if you were following the thread
when I forwarded it to you.

Cheers,
Willy
