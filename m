From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ip_tunnel: Remove gratuitous skb scrubbing
Date: Wed, 15 Apr 2015 18:32:09 +0800
Message-ID: <20150415103209.GA4003@gondor.apana.org.au>
References: <20150415100107.GA3655@gondor.apana.org.au>
 <552E3B7A.2040701@6wind.com>
 <20150415102229.GA3917@gondor.apana.org.au>
 <552E3D5E.6090103@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:47491 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755719AbbDOKcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 06:32:12 -0400
Content-Disposition: inline
In-Reply-To: <552E3D5E.6090103@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 15, 2015 at 12:28:46PM +0200, Nicolas Dichtel wrote:
>
> Here is the thread about the mark:
> http://thread.gmane.org/gmane.linux.network/246876/focus=274528

Thanks but I don't see any justification for breaking the mark
feature.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
