From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] bonding: add better ipv6 failover support
Date: Wed, 01 Oct 2008 06:36:13 -0700 (PDT)
Message-ID: <20081001.063613.29345775.davem@davemloft.net>
References: <48DBB181.9050205@hp.com>
	<20081001055355.GA27304@verge.net.au>
	<48E379F8.7090403@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: horms@verge.net.au, fubar@us.ibm.com, vladislav.yasevich@hp.com,
	alexandre.sidorenko@hp.com, jeff@garzik.org, netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37531
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750895AbYJANgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 09:36:25 -0400
In-Reply-To: <48E379F8.7090403@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Wed, 01 Oct 2008 09:24:08 -0400

> I actually figured out how to do this without having a new Kconfig
> option at all, and building bonding_ipv6.c without getting a linker
> error.  I'll send out an updated patch soon, just sorting out the
> vlan support right now.
> 

Great, I'll wait for that meanwhile, thanks everyone.
