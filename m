From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH iptables] iptables: snat: add randomize-full support
Date: Sat, 4 Jan 2014 00:43:32 +0100
Message-ID: <20140103234332.GA27882@localhost>
References: <20131219134007.GA24118@order.stressinduktion.org>
 <52B37F6B.9010105@redhat.com>
 <20131220004822.GC32129@order.stressinduktion.org>
 <20131220080118.GA4234@localhost>
 <20131220214029.GB14073@order.stressinduktion.org>
 <20131222031538.GJ14073@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Daniel Borkmann <dborkman@redhat.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40174 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753834AbaACXni (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jan 2014 18:43:38 -0500
Content-Disposition: inline
In-Reply-To: <20131222031538.GJ14073@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 22, 2013 at 04:15:38AM +0100, Hannes Frederic Sowa wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> 
> This patch provides the user space part for dnat in order to make
> randomize-full support available in {ip,nf}tables. It allows for
> enabling full port randomization that was motivated in [1] and
> introduced to the kernel in [2].
> 
> Joint work between Hannes Frederic Sowa and Daniel Borkmann.

Applied to iptables-next, thanks.
