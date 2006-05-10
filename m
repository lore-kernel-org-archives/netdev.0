From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC 0/3] [IPSEC]: Add xfrm_mode support
Date: Wed, 10 May 2006 13:54:11 -0700 (PDT)
Message-ID: <20060510.135411.80210791.davem@davemloft.net>
References: <20060419110209.GA15584@gondor.apana.org.au>
	<Pine.SOL.4.64.0604191529100.11141@kekkonen.cs.hut.fi>
	<20060506112026.GA27671@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: miika@iki.fi, Diego.Beltrami@hiit.fi, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20154
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964877AbWEJUy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 16:54:28 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060506112026.GA27671@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 6 May 2006 21:20:26 +1000

> These patches abstract out the protocol-specific encapsulation parts of
> IPsec into what I've termed xfrm_mode objects.  This allows us to share
> a little bit more code.  But more importantly, it allows us to add new
> encapsulation modes such as BEET or v4/v6 and v6/v4 without polluting
> the generic xfrm_input/xfrm_output paths.
> 
> These patches are not yet ready to be applied as I need to test them
> a bit more.

These patches look fantastic.  Let me know when you are done
testing them, have a final version, and they can be applied.

Thanks.
