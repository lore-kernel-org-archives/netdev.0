From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 6/6] rhashtable: Move future_tbl into struct bucket_table
Date: Fri, 13 Mar 2015 16:13:16 +0000
Message-ID: <20150313161316.GH17829@casper.infradead.org>
References: <20150313095607.GA598@gondor.apana.org.au>
 <E1YWMLD-0000CV-VK@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57846 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755695AbbCMQNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 12:13:17 -0400
Content-Disposition: inline
In-Reply-To: <E1YWMLD-0000CV-VK@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/15 at 08:57pm, Herbert Xu wrote:
> This patch moves future_tbl to open up the possibility of having
> multiple rehashes on the same table.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Thomas Graf <tgraf@suug.ch>
