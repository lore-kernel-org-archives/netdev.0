From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: net: Fix skb_set_peeked use-after-free bug
Date: Wed, 5 Aug 2015 08:09:25 +0800
Message-ID: <20150805000925.GB2725@gondor.apana.org.au>
References: <CAMUH3-WyNR+2tsKgZ2qMNR=p+2Q3WDjcPrQcVSZfVSVyPA1qoA@mail.gmail.com>
 <20150804074247.GA29951@gondor.apana.org.au>
 <CAMUH3-Uu4FH1hkMYeLb8BTRDPEC3WPhb7hksn9-FPfEy_2dBJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	khlebnikov@yandex-team.ru
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:53644 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbbHEAJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 20:09:30 -0400
Content-Disposition: inline
In-Reply-To: <CAMUH3-Uu4FH1hkMYeLb8BTRDPEC3WPhb7hksn9-FPfEy_2dBJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 04, 2015 at 08:30:23AM -0700, Brenden Blanco wrote:
>
> This patch holds good in my testing. Thanks!

Thanks for testing.  Let's add a tag for patchwork:

Tested-by: Brenden Blanco <bblanco@plumgrid.com>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
