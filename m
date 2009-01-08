From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
	2.6.27
Date: Fri, 9 Jan 2009 08:54:04 +1100
Message-ID: <20090108215404.GA8671@gondor.apana.org.au>
References: <20081229214101.4c4f5ac1.akpm@linux-foundation.org> <Pine.LNX.4.64.0812311241490.3120@wrl-59.cs.helsinki.fi> <495BFEAF.6000006@haveacry.com> <20090102083402.GA24383@gondor.apana.org.au> <4961ECD2.1000502@haveacry.com> <20090107041732.GA22041@gondor.apana.org.au> <4964B303.4020708@haveacry.com> <20090108030745.GA1204@gondor.apana.org.au> <4966160A.20001@haveacry.com> <20090108083753.14670943@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Speedster <speedster@haveacry.com>,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60201 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751031AbZAHVyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 16:54:16 -0500
Content-Disposition: inline
In-Reply-To: <20090108083753.14670943@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2009 at 08:37:53AM -0800, Stephen Hemminger wrote:
>
> Maybe there is an issue that GRO receive isn't handling padding
> properly?

You are one release early Stephen :) Also GRO can't be enabled
without ethtool yet.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
