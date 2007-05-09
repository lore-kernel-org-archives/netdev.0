From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linkwatch bustage in git-net
Date: Wed, 9 May 2007 14:45:59 -0700
Message-ID: <20070509144559.79b83f7e.akpm@linux-foundation.org>
References: <20070509071614.GA2138@gondor.apana.org.au>
	<20070509.001814.116354599.davem@davemloft.net>
	<20070509141103.9de0f654.akpm@linux-foundation.org>
	<20070509.143925.25157363.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:54892 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757311AbXEIVqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 17:46:47 -0400
In-Reply-To: <20070509.143925.25157363.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 09 May 2007 14:39:25 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> > where'd it go?
> 
> Look at the two individual changes, Herbert implemented the
> delay calculations different in the second changeset.  So
> the code is much different there now.

ah, OK, I just haven't learned to read diffs yet ;)
