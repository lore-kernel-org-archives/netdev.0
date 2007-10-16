From: Patrick McHardy <kaber@trash.net>
Subject: Re: [0/12] Trying to merge xfrm input path before I got side-tracked...
Date: Tue, 16 Oct 2007 16:39:56 +0200
Message-ID: <4714CD3C.801@trash.net>
References: <20071016141843.GA11956@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43036 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754137AbXJPOkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 10:40:15 -0400
In-Reply-To: <20071016141843.GA11956@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Hi Dave:
> 
> I was well on my way to merging the xfrm input path before I got
> side-tracked by inter-family transforms :)
> 
> Anyway, here's a dump of what I've got.  The one note-worthy bit
> is the patch to reinject transport mode packets through netif_rx
> rather than calling netfilter directly.
> 
> Everything else is pretty mundane (modulo any bugs of course).


I think your patches didn't make it to netdev because the last
address missed a closing '>'.
