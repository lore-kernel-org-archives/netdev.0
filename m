From: David Miller <davem@davemloft.net>
Subject: Re: lib: rhashtable - Remove weird non-ASCII characters from
 comments
Date: Thu, 13 Nov 2014 14:39:15 -0500 (EST)
Message-ID: <20141113.143915.1710253272286808322.davem@davemloft.net>
References: <20141113051048.GA1801@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58759 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933146AbaKMTjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 14:39:17 -0500
In-Reply-To: <20141113051048.GA1801@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 13 Nov 2014 13:10:48 +0800

> My editor spewed garbage that looked like memory corruption on
> my screen.  It turns out that a number of occurences of "fi" got
> turned into a ligature.
>     
> This patch replaces these ligatures with the ASCII letters "fi".
>     
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks :)
