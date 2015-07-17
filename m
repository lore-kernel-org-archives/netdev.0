From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sit: Set SKB_GSO_SIT bit when performing GRO
Date: Fri, 17 Jul 2015 09:56:51 +0800
Message-ID: <20150717015651.GA19315@gondor.apana.org.au>
References: <17762800.UBb5paxXY3@h2o.as.studentenwerk.mhn.de>
 <2477915.Hv2mXUtnDZ@stwm.de>
 <20150716002350.GA7529@gondor.apana.org.au>
 <2115027.IFUsFvOUns@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Tom Herbert <tom@herbertland.com>
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:40939 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761AbbGQB46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 21:56:58 -0400
Content-Disposition: inline
In-Reply-To: <2115027.IFUsFvOUns@stwm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 16, 2015 at 12:58:45PM +0200, Wolfgang Walter wrote:
> Am Donnerstag, 16. Juli 2015, 08:23:50 schrieb Herbert Xu:
> > On Wed, Jul 15, 2015 at 02:25:59PM +0200, Wolfgang Walter wrote:
> > > Yes. Switching TSO off and leaving GRO on works, too.
> > 
> > OK, could you please try this patch?
> 
> Patch works here.

Thanks for the confirmation.  Let's add a tag for patchwork:

Tested-by: Wolfgang Walter <linux@stwm.de>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
