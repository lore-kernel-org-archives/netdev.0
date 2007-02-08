From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: [PATCH 1/5] Add PCBC crypto template support
Date: Fri, 9 Feb 2007 08:32:46 +1100
Message-ID: <20070208213246.GA17500@gondor.apana.org.au>
References: <20070208163211.23973.5877.stgit@warthog.cambridge.redhat.com> <20070208163219.23973.8679.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4689 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1423425AbXBHVdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 16:33:01 -0500
Content-Disposition: inline
In-Reply-To: <20070208163219.23973.8679.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 08, 2007 at 04:32:19PM +0000, David Howells wrote:
> Add PCBC crypto template support as used by RxRPC.
> 
> Signed-Off-By: David Howells <dhowells@redhat.com>

This is already in the crypto-2.6 tree that I pushed
yesterday.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
