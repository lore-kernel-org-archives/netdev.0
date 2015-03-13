From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/6] rhashtable: Use SINGLE_DEPTH_NESTING
Date: Fri, 13 Mar 2015 15:40:22 +0000
Message-ID: <20150313154022.GD17829@casper.infradead.org>
References: <20150313095607.GA598@gondor.apana.org.au>
 <E1YWML9-0000BP-B0@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57601 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756722AbbCMPkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 11:40:24 -0400
Content-Disposition: inline
In-Reply-To: <E1YWML9-0000BP-B0@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/15 at 08:57pm, Herbert Xu wrote:
> We only nest one level deep there is no need to roll our own
> subclasses.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Thomas Graf <tgraf@suug.ch>
