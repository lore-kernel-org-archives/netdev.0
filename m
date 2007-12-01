From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] XFRM: SPD auditing fix to include the netmask/prefix-length
Date: Sat, 1 Dec 2007 23:28:34 +1100
Message-ID: <20071201122834.GA15910@gondor.apana.org.au>
References: <20071126195512.6176.10448.stgit@flek.americas.hpqcorp.net> <20071129103459.GD22537@gondor.apana.org.au> <200711290845.46623.paul.moore@hp.com> <200711300951.48964.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-audit@redhat.com, Joy Latten <latten@us.ibm.com>,
	Steve Grubb <sgrubb@redhat.com>, netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3175 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752772AbXLAM2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 07:28:55 -0500
Content-Disposition: inline
In-Reply-To: <200711300951.48964.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 30, 2007 at 09:51:48AM -0500, Paul Moore wrote:
>
> Steve and/or Joy, could we get a verdict on this issue?  The lack of a netmask 
> in the SPD audit messages is pretty serious so I'd like to see this fixed as 
> soon as possible.

I'll take the resounding silence as an indication of approval :)

Patch applied to net-2.6.25.  Thanks Paul.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
