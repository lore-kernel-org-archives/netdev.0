From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next 0/3] Kill arch_fast_hash
Date: Thu, 11 Dec 2014 21:35:54 +1100
Message-ID: <20141211103554.GA11471@gondor.apana.org.au>
References: <1418225592-29322-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, tgraf@suug.ch,
	hannes@stressinduktion.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:44453 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754677AbaLKKgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 05:36:08 -0500
Content-Disposition: inline
In-Reply-To: <1418225592-29322-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann <dborkman@redhat.com> wrote:
> Due to the size of changes I have based this against net-next,
> also given 3.18 is already out. I've split this into 3 parts,
> the first two to remove existing users (so they can optionally
> go to stable) and the last one to kill the remaining library bits.
> 
> Let me know if there are any issues.

Thanks for the fast response Daniel!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
