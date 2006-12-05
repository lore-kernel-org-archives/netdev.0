From: David Miller <davem@davemloft.net>
Subject: Re: dm-crypt changes in git-net tree
Date: Tue, 05 Dec 2006 13:42:50 -0800 (PST)
Message-ID: <20061205.134250.11387254.davem@davemloft.net>
References: <20061204225907.6b486e57.akpm@osdl.org>
	<20061205084041.GA25615@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, rsnel@cube.dyndns.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48044
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031664AbWLEVmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 16:42:44 -0500
To: herbert@gondor.apana.org.au
In-Reply-To: <20061205084041.GA25615@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 5 Dec 2006 19:40:41 +1100

> [CRYPTO] dm-crypt: Make iv_gen_private a union
> 
> Rather than stuffing integers into pointers with casts, let's use
> a union.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
