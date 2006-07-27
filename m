From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND 3/5] [NET]: Protocol Independant Policy Routing Rules
 Framework
Date: Thu, 27 Jul 2006 16:17:46 -0700 (PDT)
Message-ID: <20060727.161746.120621542.davem@davemloft.net>
References: <20060726.230230.111423566.davem@davemloft.net>
	<20060727223931.GZ14627@postel.suug.ch>
	<44C94529.5080605@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, jmorris@namei.org, netdev@vger.kernel.org,
	vnuorval@tcs.hut.fi, usagi-core@linux-ipv6.org,
	yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20926
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750874AbWG0XRX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 19:17:23 -0400
To: kaber@trash.net
In-Reply-To: <44C94529.5080605@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 28 Jul 2006 00:58:49 +0200

> Thomas Graf wrote:
> > Derived from net/ipv6/fib_rules.c
> 
> This clashes with my routing table patch, guess we have to figure
> out who should go first :)

I think since USAGI has some work that depends on this, we
should get Thomas's stuff in first.

It shouldn't be a big deal to rework your >256 tables patch
against Thomas's should it?

