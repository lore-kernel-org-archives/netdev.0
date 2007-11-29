From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket filter
Date: Thu, 29 Nov 2007 21:38:56 +1100
Message-ID: <20071129103856.GE22537@gondor.apana.org.au>
References: <20071119.142313.63549156.davem@davemloft.net> <20071120002945.91fafb2b.billfink@mindspring.com> <20071120140518.GA1502@one.firstfloor.org> <20071120.173928.53148729.davem@davemloft.net> <474E707A.3080106@cn.fujitsu.com> <20071129092136.GB30066@gondor.apana.org.au> <474E8F9E.7040309@cn.fujitsu.com> <20071129102122.GA22537@gondor.apana.org.au> <474E955D.7010108@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	netdev@vger.kernel.org, gerrit@erg.abdn.ac.uk,
	bfields@fieldses.org, neilb@suse.de
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1903 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751722AbXK2KjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 05:39:11 -0500
Content-Disposition: inline
In-Reply-To: <474E955D.7010108@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 29, 2007 at 06:33:01PM +0800, Wang Chen wrote:
>
> I cooked the patch based on Andi's and left the new counter.
> Frankly, I don't like the EarlyDatagrams too.
> So, I will remove it and resubmit.

Sounds good.  Thanks for all your efforts on this problem!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
