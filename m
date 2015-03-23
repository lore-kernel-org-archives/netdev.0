From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v2 PATCH 4/10] netlink: Use default rhashtable hashfn
Date: Mon, 23 Mar 2015 23:56:23 +1100
Message-ID: <20150323125623.GA15743@gondor.apana.org.au>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZara-0000vP-C0@gondolin.me.apana.org.au>
 <20150323011817.GC20755@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:54303 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbbCWM4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 08:56:51 -0400
Content-Disposition: inline
In-Reply-To: <20150323011817.GC20755@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 10:18:21AM +0900, Simon Horman wrote:
>
> I understand the above change in the context of the rest of the series,
> however, it does not seem to match up with the changelog for this patch.

OK I will update the changelog.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
