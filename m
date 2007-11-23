From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][IPv6] Correct the comment concerning inetsw6 table
Date: Fri, 23 Nov 2007 21:30:25 +0800
Message-ID: <20071123133025.GJ18862@gondor.apana.org.au>
References: <47469612.2020900@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1182 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752668AbXKWNa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 08:30:27 -0500
Content-Disposition: inline
In-Reply-To: <47469612.2020900@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 23, 2007 at 11:57:54AM +0300, Pavel Emelyanov wrote:
> It seems that net/ipv6/af_inet6.c was copied from net/ipv4/af_inet.c,
> but one comment was not fixed.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.

Oh and congratulations for advancing in the Order of Pedantry :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
