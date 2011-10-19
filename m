From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ipvs: Remove unused variable "cs" from ip_vs_leave
 function.
Date: Wed, 19 Oct 2011 13:11:12 +0200
Message-ID: <20111019111112.GB10008@1984>
References: <1318967989-14076-1-git-send-email-krzysztof.wilczynski@linux.com>
 <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903183@ESESSCMS0356.eemea.ericsson.se>
 <CAC52Y8ZvgBVC4_TEBFMALa-xU84PseV6w6sJO64ch+BdAqD2aA@mail.gmail.com>
 <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903185@ESESSCMS0356.eemea.ericsson.se>
 <20111019104945.GA17995@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hans =?iso-8859-1?Q?Schillstr=F6m?=
	<hans.schillstrom@ericsson.com>,
	Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35404 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750731Ab1JSLLT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Oct 2011 07:11:19 -0400
Content-Disposition: inline
In-Reply-To: <20111019104945.GA17995@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 19, 2011 at 07:49:57PM +0900, Simon Horman wrote:
> Yes, it seems that Pablo has picked up the change but
> it hasn't propagated to Dave's tree for one reason or another.

I was waiting for david to take bugfixes for his net tree. This
happened yesterday. Now I'll send updates for net-next.

I expect to make it along today, please, be patient, they'll show up
in david's net-next tree soon :-)
