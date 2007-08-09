From: Kyle McMartin <kyle@parisc-linux.org>
Subject: Re: [PATCH 14/24] make atomic_read() behave consistently on parisc
Date: Thu, 9 Aug 2007 12:45:34 -0400
Message-ID: <20070809164534.GC27558@fattire.cabal.ca>
References: <20070809140154.GA17489@shell.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stout.engsoc.carleton.ca ([134.117.69.22]:54526 "EHLO
	stout.engsoc.carleton.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966285AbXHIQpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 12:45:36 -0400
Content-Disposition: inline
In-Reply-To: <20070809140154.GA17489@shell.boston.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 09, 2007 at 10:01:54AM -0400, Chris Snook wrote:
> From: Chris Snook <csnook@redhat.com>
> 
> Purify volatile use for atomic[64]_t on parisc.
> 
> Signed-off-by: Chris Snook <csnook@redhat.com>
> 

Sure, why not.

ACKed-by: Kyle McMartin <kyle@parisc-linux.org>
