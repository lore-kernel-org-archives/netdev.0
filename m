From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [IP] xfrm: Allow replay setting
Date: Fri, 9 May 2008 15:52:14 -0700
Message-ID: <20080509155214.35fb4b71@extreme>
References: <20080423074232.GA29974@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jamal <hadi@cyberus.ca>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46669 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754811AbYEIWyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 18:54:04 -0400
In-Reply-To: <20080423074232.GA29974@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Apr 2008 15:42:32 +0800
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Hi Stephen:
> 
> [IP] xfrm: Allow replay setting
> 
> For certain applications there is a requirement to start the
> sequence number from a point other than the default.  As it
> is the kernel provides an interface to do that but it isn't
> available through the ip(8) command.  Since we're encouraging
> people to migrate over to ip(8) for manual keying, it is useful
> to have this ability there.
> 
> This patch adds support for setting replay sequence numbers
> through ip(8).
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Thanks,
applied, thanks
