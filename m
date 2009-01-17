From: Divy Le Ray <divy@chelsio.com>
Subject: Re: cxgb3: Replace LRO with GRO
Date: Sat, 17 Jan 2009 03:11:26 -0800
Message-ID: <4971BCDE.50600@chelsio.com>
References: <20090115235803.GA9000@gondor.apana.org.au> <49704015.6020503@chelsio.com> <20090116085645.GA14678@gondor.apana.org.au> <49706B87.7080806@chelsio.com> <20090117050839.GA24215@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:31708 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755887AbZAQLMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2009 06:12:40 -0500
In-Reply-To: <20090117050839.GA24215@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Hi Divy:
> 
> On Fri, Jan 16, 2009 at 03:12:07AM -0800, Divy Le Ray wrote:
>>        1.112500  __alloc_skb                         vmlinux
> 
> Can you confirm that you were testing 1500 byte packets?

Yes.

Cheers,
Divy
