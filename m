From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
	2.6.27
Date: Fri, 2 Jan 2009 19:34:02 +1100
Message-ID: <20090102083402.GA24383@gondor.apana.org.au>
References: <bug-12327-10286@http.bugzilla.kernel.org/> <20081229214101.4c4f5ac1.akpm@linux-foundation.org> <Pine.LNX.4.64.0812311241490.3120@wrl-59.cs.helsinki.fi> <495BFEAF.6000006@haveacry.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Speedster <speedster@haveacry.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:56255 "EHLO arnor.apana.org.au"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751141AbZABIhr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jan 2009 03:37:47 -0500
Content-Disposition: inline
In-Reply-To: <495BFEAF.6000006@haveacry.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2008 at 11:22:23PM +0000, Speedster wrote:
>
> The gateway machine (whinge) runs as a KVM guest, and shares a physical  
> host with three other guests (one Windows, two Linux). Below are the  
> outputs of bridge topology and VLAN tagging on the physical host.

What driver are you using on whinge?

When you took the packet dumps, was it on whinge or the physical
host? If it was taken on whinge, can you try to take the same
dumps on the outgoing physical interface on the host?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
