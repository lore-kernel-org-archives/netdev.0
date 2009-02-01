From: David Miller <davem@davemloft.net>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Sun, 01 Feb 2009 01:07:42 -0800 (PST)
Message-ID: <20090201.010742.175751729.davem@davemloft.net>
References: <498349F7.4050300@cosmosbay.com>
	<20090130215008.GB12210@ioremap.net>
	<20090131215850.3dfc29fb@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, dada1@cosmosbay.com, herbert@gondor.apana.org.au,
	berrange@redhat.com, et-mgmt-tools@redhat.com,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39829
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751797AbZBAJHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 04:07:45 -0500
In-Reply-To: <20090131215850.3dfc29fb@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sat, 31 Jan 2009 21:58:50 -0800

> Yes, this fixes the problem, not sure who wants the honors for
> sending a signed off version.

I'll sort it out.
