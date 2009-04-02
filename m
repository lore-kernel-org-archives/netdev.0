From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 2 Apr 2009 17:05:18 +0800
Message-ID: <20090402090518.GA30039@gondor.apana.org.au>
References: <20090402030935.GA27836@gondor.apana.org.au> <49D45F59.9030100@redhat.com> <20090402085411.GA29967@gondor.apana.org.au> <49D47F64.3020709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anthony Liguori <anthony@codemonkey.ws>, andi@firstfloor.org,
	ghaskins@novell.com, linux-kernel@vger.kernel.org, agraf@suse.de,
	pmullaney@novell.com, pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58399 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752858AbZDBJFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 05:05:34 -0400
Content-Disposition: inline
In-Reply-To: <49D47F64.3020709@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 02, 2009 at 12:03:32PM +0300, Avi Kivity wrote:
>
> Like Anthony said, the problem is with the kernel->user interfaces.  We  
> won't have a good user space virtio implementation until that is fixed.

If it's just the interface that's bad, then it should be possible
to do a proof-of-concept patch to show that this is the case.

Even if we have to redesign the interface, at least you can then
say that you guys were right all along :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
