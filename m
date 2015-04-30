From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next 1/2] rhashtable: Simplify iterator code
Date: Fri, 1 May 2015 07:41:43 +0800
Message-ID: <20150430234143.GA31123@gondor.apana.org.au>
References: <1430434005-6143-2-git-send-email-tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:51335 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbbD3Xlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 19:41:55 -0400
Content-Disposition: inline
In-Reply-To: <1430434005-6143-2-git-send-email-tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf <tgraf@suug.ch> wrote:
> Remove useless obj variable and goto logic.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
