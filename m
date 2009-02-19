From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.29 regression? Bonding tied to IPV6 in 29-rc5
Date: Thu, 19 Feb 2009 21:32:48 +0800
Message-ID: <20090219133248.GA11181@gondor.apana.org.au>
References: <499C681A.6000008@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org,
	vladislav.yasevich@hp.com, chuck.lever@oracle.com, tytso@mit.edu,
	Valdis.Kletnieks@vt.edu, arvidjaar@mail.ru, rjw@sisk.pl,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	jamagallon@ono.com, linux-kernel@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54735 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751505AbZBSNdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 08:33:16 -0500
Content-Disposition: inline
In-Reply-To: <499C681A.6000008@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley <brian.haley@hp.com> wrote:
> 
> There does seem to be a sysctl for it, just doesn't seem to work. 

OK we should definitely fix that.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
