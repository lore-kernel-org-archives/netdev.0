From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [IPV4] LVS: Allow to send ICMP unreachable responses when
 real-servers are removed
Date: Thu, 21 Jun 2007 10:56:43 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0706211045300.2568@u.domain.uli>
References: <Pine.LNX.4.58.0705160012470.2626@u.domain.uli>  <200705301138.29582@nienna>
 <Pine.LNX.4.58.0705310239240.3745@u.domain.uli>  <200705311450.36492@nienna>
 <Pine.LNX.4.58.0706010123020.2683@u.domain.uli> <1182337041.15676.23.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: KOVACS Krisztian <hidden@balabit.hu>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	horms@verge.net.au, jkrzyszt@tis.icnet.pl, netdev@vger.kernel.org
To: Balazs Scheidler <bazsi@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:3361 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751528AbXFUH5u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2007 03:57:50 -0400
In-Reply-To: <1182337041.15676.23.camel@bzorp.balabit>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 20 Jun 2007, Balazs Scheidler wrote:

> Is there a chance that this, or a patch with similar spirit (e.g. a way
> to send packets from non-local IP addresses) could be merged?

	Last patch from Krisztian is exactly what I preferred
to see, I hope that someone really tested it :). But i'm not the one
that decides, so far we don't see comments from other interested
parties, may be there are other opinions?

Regards

--
Julian Anastasov <ja@ssi.bg>
