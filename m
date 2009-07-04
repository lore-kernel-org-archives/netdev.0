From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] net: skb_orphan on dev_hard_start_xmit
Date: Sat, 4 Jul 2009 11:08:30 +0800
Message-ID: <20090704030830.GA32442@gondor.apana.org.au>
References: <20090602.171418.186096253.davem@davemloft.net> <20090703075530.GA25190@gondor.apana.org.au> <20090703.200254.172991821.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, patrick.ohly@intel.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	divy@chelsio.com, rolandd@cisco.com, xemul@openvz.org,
	dcbw@redhat.com, libertas-dev@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36565 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751731AbZGDDIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 23:08:38 -0400
Content-Disposition: inline
In-Reply-To: <20090703.200254.172991821.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 03, 2009 at 08:02:54PM -0700, David Miller wrote:
>
> In particular the case of handling a device without usable TX
> completion event indications is still quite troublesome.

Which particular devices do you have in mind?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
