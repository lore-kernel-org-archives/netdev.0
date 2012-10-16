From: Willy Tarreau <w@1wt.eu>
Subject: Re: [stable 2.6.32.y] net/ipv4: fix cached ipv4 dsts never invalidated
Date: Tue, 16 Oct 2012 23:22:15 +0200
Message-ID: <20121016212215.GJ31152@1wt.eu>
References: <20121016203449.GA25889@kvack.org> <20121016.164539.753785374589743655.davem@davemloft.net> <20121016204955.GA25971@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:32909 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752918Ab2JPVYL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2012 17:24:11 -0400
Content-Disposition: inline
In-Reply-To: <20121016204955.GA25971@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 16, 2012 at 04:49:55PM -0400, Benjamin LaHaise wrote:
> On Tue, Oct 16, 2012 at 04:45:39PM -0400, David Miller wrote:
> > This is only a partial fix.
> > 
> > Only recently did this issue get resolved completely.
> > 
> > See commits surrounding:
> 
> Thanks for the pointers David.  I'll cherry pick / backport the relevant 
> changes for Willy as well.

They will be much welcome, thank you guys !

Willy
