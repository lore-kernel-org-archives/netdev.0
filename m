From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [ANNOUNCE] iproute2-2.6.23
Date: Tue, 23 Oct 2007 08:37:02 -0700
Message-ID: <20071023083702.2904c0a0@shemminger-laptop>
References: <20071016164439.3f8a4f00@freepuppy.rosehill>
	<E1IhxQA-0004gh-00@gondolin.me.apana.org.au>
	<20071023061207.GA27560@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40963 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751992AbXJWPhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 11:37:38 -0400
In-Reply-To: <20071023061207.GA27560@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 23 Oct 2007 14:12:07 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, Oct 17, 2007 at 09:10:02AM +0800, Herbert Xu wrote:
> > 
> > Any chance you could include the NAT patch for the next release?
> > 
> > [TC]: Add NAT action
> > 
> > This patch adds the parser for the nat action which is used
> > for stateless NAT.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Hi Stephen:
> 
> Is there a problem with merging this patch?

I was just holding off for a few days to see if there were any bug fixes
to 2.6.23 version that needed to go in first. It is first in queue for 2.6.24
related stuff.

Promise to get it in before 2.6.24-rc1
