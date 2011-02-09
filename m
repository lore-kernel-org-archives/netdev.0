From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [Bugme-new] [Bug 28282] New: forwarding turns autoconfiguration off
Date: Wed, 9 Feb 2011 08:42:21 +0100
Message-ID: <20110209074221.GA9790@electric-eye.fr.zoreil.com>
References: <20110208133408.7d447e6a.akpm@linux-foundation.org> <20110208.134421.39185637.davem@davemloft.net> <4D51BFCE.2070405@msgid.danisch.de> <20110208.143046.246534138.davem@davemloft.net> <20110208224411.GA9674@electric-eye.fr.zoreil.com> <20110208234753.48abd902.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, hadmut@danisch.de,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49631 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752197Ab1BIHpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Feb 2011 02:45:33 -0500
Content-Disposition: inline
In-Reply-To: <20110208234753.48abd902.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink <billfink@mindspring.com> :
[...]
> I believe there is a difference between being a router and merely
> being capable of forwarding IP packets.  To me, a router participates
> in a routing protocol and/or advertises routes/prefixes.  So perhaps
> Hadmut has a valid point that autoconfiguration should not depend
> on ip_forward being off, although I'm not sure what the appropriate
> alternate test for not being a router should be.

It is here (same document, same page):
[...]
2.  Terminology

   IP -  Internet Protocol Version 6.  The terms IPv4 and IPv6 are used
      only in contexts where necessary to avoid ambiguity.

   node -  a device that implements IP.

   router -  a node that forwards IP packets not explicitly addressed to
      itself.

Why should we put our brains at pain ? Is there really a problem ?

-- 
Ueimor
