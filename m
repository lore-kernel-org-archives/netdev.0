From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.17-rc6-mm1 ] net: RFC 3828-compliant UDP-Lite
 support
Date: Thu, 08 Jun 2006 15:13:47 -0700 (PDT)
Message-ID: <20060608.151347.55505744.davem@davemloft.net>
References: <20060608.115331.71094388.davem@davemloft.net>
	<Pine.LNX.4.64.0606081542390.3555@d.namei>
	<200606082109.34338.gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, alan@lxorguk.ukuu.org.uk, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, yoshfuji@linux-ipv6.org, kaber@coreworks.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:10945
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965012AbWFHWNq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 18:13:46 -0400
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200606082109.34338.gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 8 Jun 2006 21:09:33 +0100

> That is why I held back regarding the IPv6 port: I can ensure that
> this (IPv4) code is up to standard and to date, but am lacking the
> required additional time to implement the same for IPv6.  I am
> trying to contact people to help with the port, but for the moment I
> will take responsibility only for the IPv4 version.

It's not like an ipv6 port is such a big pile of work.

I'd say it would take you an afternoon, max.

You don't have to test it to the point where it is ISO9000 compliant,
that's not what is being asked of you.
