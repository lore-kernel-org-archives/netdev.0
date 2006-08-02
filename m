From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Mobile IPv6 introduction
Date: Wed, 02 Aug 2006 14:14:01 -0700 (PDT)
Message-ID: <20060802.141401.105110100.davem@davemloft.net>
References: <44D01AEE.3030606@linux-ipv6.org>
	<20060802104756.GN8334@innerghost.net>
	<44D0A294.5000208@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hsantos@av.it.pt, yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi,
	vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:25504
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932176AbWHBVNw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 17:13:52 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <44D0A294.5000208@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Wed, 02 Aug 2006 22:03:16 +0900

> If there is much requirement to add new type number without any
> modification of kernel code at all I would support ICMPv6 filter
> approach, too.

There is no such requirement, please just continue to prepare
your current patches for inclusion.

There is a limit to how much nit-picking we can do for such
a large body of work, and we should thus take evolutionary
approach to this work.  We can make all kinds of refinements
later to improve the implementation.
