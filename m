From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] e1000: drop lltx, remove unnecessary lock
Date: Thu, 22 Jan 2009 09:34:18 +1100
Message-ID: <20090121223418.GA8557@gondor.apana.org.au>
References: <20090121083407.538.47112.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	jeffrey.t.kirsher@intel.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42557 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753283AbZAUWeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 17:34:22 -0500
Content-Disposition: inline
In-Reply-To: <20090121083407.538.47112.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> LLTX is deprecated, don't use it.  This completes the removal of LLTX from
> the Intel Network drivers.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Awesome work Jeff :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
