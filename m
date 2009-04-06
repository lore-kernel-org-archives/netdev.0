From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: ip6tables fix
Date: Mon, 06 Apr 2009 17:08:31 +0200
Message-ID: <49DA1AEF.10105@trash.net>
References: <20090329234702.4988017f@desktop.r000n.info>	<8763hja8cy.fsf@newton.gmurray.org.uk>	<20090405.012237.198610462.davem@davemloft.net>	<49D88162.5040809@cosmosbay.com> <87ws9z8l4c.fsf@newton.gmurray.org.uk> <49D88839.4090902@cosmosbay.com> <49D8A445.4060201@cosmosbay.com> <49D8A6BB.5000700@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Graham Murray <graham@gmurray.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48290 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751235AbZDFPIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 11:08:37 -0400
In-Reply-To: <49D8A6BB.5000700@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> [PATCH] netfilter: ip6tables fix
> 
> ip6_tables.c alloc_counters() misses a return statement, making
> ip6tables -L always failing.
> 
> Reported-by: Graham Murray <graham@gmurray.org.uk>
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
