From: Thomas Graf <tgraf@suug.ch>
Subject: Re: lib: rhashtable - Remove weird non-ASCII characters from comments
Date: Thu, 13 Nov 2014 07:54:02 +0000
Message-ID: <20141113075402.GL19157@casper.infradead.org>
References: <20141113051048.GA1801@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49483 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811AbaKMHyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 02:54:04 -0500
Content-Disposition: inline
In-Reply-To: <20141113051048.GA1801@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/14 at 01:10pm, Herbert Xu wrote:
> My editor spewed garbage that looked like memory corruption on
> my screen.  It turns out that a number of occurences of "fi" got
> turned into a ligature.
>     
> This patch replaces these ligatures with the ASCII letters "fi".
>     
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Fun ;-) These are the comments I copied from the PDF whitepaper.

Acked-by: Thomas Graf <tgraf@suug.ch>
