From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/4] rhashtable: Remove key length argument to key_hashfn
Date: Thu, 12 Mar 2015 14:13:07 +0000
Message-ID: <20150312141307.GC4001@casper.infradead.org>
References: <20150312034923.GA14415@gondor.apana.org.au>
 <E1YVu7w-0003lx-DS@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50303 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754003AbbCLONI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 10:13:08 -0400
Content-Disposition: inline
In-Reply-To: <E1YVu7w-0003lx-DS@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/15 at 02:49pm, Herbert Xu wrote:
> key_hashfn has only one caller and it doesn't really need to supply
> the key length as an extra parameter.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Thomas Graf <tgraf@suug.ch>
