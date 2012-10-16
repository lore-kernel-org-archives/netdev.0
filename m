From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [stable 2.6.32.y] net/ipv4: fix cached ipv4 dsts never invalidated
Date: Tue, 16 Oct 2012 16:49:55 -0400
Message-ID: <20121016204955.GA25971@kvack.org>
References: <20121016203449.GA25889@kvack.org> <20121016.164539.753785374589743655.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: w@1wt.eu, stable@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:56888 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751947Ab2JPUt4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2012 16:49:56 -0400
Content-Disposition: inline
In-Reply-To: <20121016.164539.753785374589743655.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 16, 2012 at 04:45:39PM -0400, David Miller wrote:
> This is only a partial fix.
> 
> Only recently did this issue get resolved completely.
> 
> See commits surrounding:

Thanks for the pointers David.  I'll cherry pick / backport the relevant 
changes for Willy as well.

		-ben
-- 
"Thought is the essence of where you are now."
