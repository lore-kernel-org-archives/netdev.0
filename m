From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 0/8] l2tp: introduce L2TPv3 support
Date: Tue, 24 Feb 2009 17:45:57 +0800
Message-ID: <20090224094557.GA21905@gondor.apana.org.au>
References: <49A3BB1E.8040005@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59770 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752190AbZBXJqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 04:46:03 -0500
Content-Disposition: inline
In-Reply-To: <49A3BB1E.8040005@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Chapman <jchapman@katalix.com> wrote:
> 
> I did, yes. I decided against it only because I didn't want to cause
> confusion with what I perhaps wrongly perceive as an API for managing
> net devices. In the L2TPv3 case, there might not be a netdev directly
> associated with a newlink API call, for example. I've no problem with
> switching the code to use it if it is preferred.

Fair enough, just making sure that it was considered at least :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
