From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [0/4] GRO optimisations
Date: Thu, 29 Jan 2009 16:37:19 -0800
Message-ID: <49824BBF.4090007@hp.com>
References: <20090130001849.GA1272@gondor.apana.org.au> <498249C9.3050708@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:6040 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755757AbZA3AhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 19:37:24 -0500
In-Reply-To: <498249C9.3050708@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Divy Le Ray wrote:
> I'll give these patches a try within a day or two.
> Please note that the 6Gb/s rate is achieved on a low perf server.
> Using this server makes it easy to witness the impact of optimizations.
> Faster boxes reach line rate.

That is what netperf service demand is for :)  so you can see the effect of 
changes even when you are link-bound.

rick jones
