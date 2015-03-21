From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/2] netfilter: preparatory patches for set extensions
Date: Sun, 22 Mar 2015 10:04:47 +1100
Message-ID: <20150321230447.GA31869@gondor.apana.org.au>
References: <1426952290-18962-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, davem@davemloft.net, tgraf@suug.ch,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:56377 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463AbbCUXFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 19:05:03 -0400
Content-Disposition: inline
In-Reply-To: <1426952290-18962-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 21, 2015 at 03:38:08PM +0000, Patrick McHardy wrote:
> 
> @Dave and Pablo: these patches apply on top of nf-next and a bunch
> of patches I just sent to Pablo, but also need Herbert's recent
> changes in net-next. Additionally I have more patches coming up
> which depend on these changes. In order to simplify things, I'd
> suggest to have the rhashtable change go through Pablo's tree if
> you don't mind.

I have more patches (multiple rehashing) coming up that will
conflict with this.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
