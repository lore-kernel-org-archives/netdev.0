From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [3.10.y-3.15.y][stable request] netfilter: nf_nat: fix oops on
 netns removal
Date: Fri, 27 Jun 2014 10:56:53 +0200
Message-ID: <20140627085653.GA4232@localhost>
References: <53AC84B1.8080405@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kamal@canonical.com,
	samu.kallio@aberdeencloud.com,
	Luis Henriques <luis.henriques@canonical.com>,
	netdev@vger.kernel.org, fw@strlen.de
To: Chris J Arges <chris.j.arges@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41384 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752740AbaF0I47 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2014 04:56:59 -0400
Content-Disposition: inline
In-Reply-To: <53AC84B1.8080405@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 26, 2014 at 03:38:09PM -0500, Chris J Arges wrote:
> Hi,
> 
> Please include commit 945b2b2d259d1a4364a2799e80e8ff32f8c6ee6f in the
> netdev stable queue and any other appropriate stable trees. This fixes a
> race condition that can be triggered when cleaning up LXC containers
> that use NAT/netns. The patch has already received positive testing when
> backported to 3.13.y.

Please wait, this is in my queue:

0006-netfilter-nf_nat-fix-oops-on-netns-removal.patch

I'll send it asap.
