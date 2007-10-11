From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: e100 problems in .23rc8 ?
Date: Thu, 11 Oct 2007 09:25:20 +0800
Message-ID: <20071011012520.GA13160@gondor.apana.org.au>
References: <46FAA083.9020604@intel.com> <E1IanKN-0003ju-00@gondolin.me.apana.org.au> <20071011003638.GA27174@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	esandeen@redhat.com, dmack@juniper.net
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4417 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750827AbXJKBZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 21:25:48 -0400
Content-Disposition: inline
In-Reply-To: <20071011003638.GA27174@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 10, 2007 at 08:36:38PM -0400, Dave Jones wrote:
> 
> The e1000 changes you reference above, is this the changeset you mean?
> 
> commit 416b5d10afdc797c21c457ade3714e8f2f75edd9
> Author: Auke Kok <auke-jan.h.kok@intel.com>
> Date:   Fri Jun 1 10:22:39 2007 -0700
> 
>     e1000: disable polling before registering netdevice

Yep.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
