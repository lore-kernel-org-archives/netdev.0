From: Diego Beltrami <Diego.Beltrami@hiit.fi>
Subject: Re: [2/4] [IPSEC] xfrm: Abstract out encapsulation modes
Date: Sat, 27 May 2006 17:20:57 +0300
Message-ID: <1148739657.447860494488a@webmail.hiit.fi>
References: <20060527113236.GA4203@gondor.apana.org.au> <20060527113425.GB4737@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:5302 "EHLO creon.otaverkko.fi")
	by vger.kernel.org with ESMTP id S1751532AbWE0OVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 May 2006 10:21:01 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060527113425.GB4737@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Herbert Xu <herbert@gondor.apana.org.au>:

> [IPSEC] xfrm: Abstract out encapsulation modes
>
> This patch adds the structure xfrm_mode.  It is meant to represent
> the operations carried out by transport/tunnel modes.
>
> By doing this we allow additional encapsulation modes to be added
> without clogging up the xfrm_input/xfrm_output paths.
>
> Candidate modes include 4-to-6 tunnel mode, 6-to-4 tunnel mode, and
> BEET modes.

Herbert,
this is a very good patch, indeed!
Well done!

--
Diego


