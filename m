From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: multicast: bug or "feature"
Date: Fri, 19 Oct 2007 19:43:27 +0800
Message-ID: <E1IiqGF-0003Vu-00@gondolin.me.apana.org.au>
References: <47178708.2040606@hp.com>
Cc: netdev@vger.kernel.org, brian.haley@hp.com, dlstevens@us.ibm.com
To: vladislav.yasevich@hp.com (Vlad Yasevich)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2782 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933158AbXJSLnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 07:43:35 -0400
In-Reply-To: <47178708.2040606@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vlad Yasevich <vladislav.yasevich@hp.com> wrote:
>
> Now, to figure out what IPv6 does different and why it works.
> Seems to me that the two should have the same behavior.

IPv6 on Linux uses a per-interface addressing model as opposed
to the per-host model used by IPv4.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
