From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: networking busted in current -git ???
Date: Sat, 09 Jun 2007 11:06:10 -0400
Message-ID: <1181401570.6240.0.camel@heimdal.trondhjem.org>
References: <20070608205640.GI30661@iucha.net>
	 <200706082307.45722.arekm@maven.pl>
	 <1181339007.6675.12.camel@heimdal.trondhjem.org>
	 <20070608.190608.117446027.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: arekm@maven.pl, florin@iucha.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:57162 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752884AbXFIPGc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2007 11:06:32 -0400
In-Reply-To: <20070608.190608.117446027.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-06-08 at 19:06 -0700, David Miller wrote:
> From: Trond Myklebust <trond.myklebust@fys.uio.no>
> Date: Fri, 08 Jun 2007 17:43:27 -0400
> 
> > It is not dhcp. I'm seeing the same bug with bog-standard ifup with a
> > static address on an FC-6 machine.
> > 
> > It appears to be something in the latest dump from davem to Linus, but I
> > haven't yet had time to identify what.
> 
> Linus's current tree should have this fixed.
> 
> Let us know if this is not the case.

It appears to be working for me again.

Trond

