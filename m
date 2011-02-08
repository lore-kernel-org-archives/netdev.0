From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [Bugme-new] [Bug 28282] New: forwarding turns autoconfiguration off
Date: Wed, 9 Feb 2011 00:49:37 +0100
Message-ID: <20110208234937.GA9710@electric-eye.fr.zoreil.com>
References: <20110208133408.7d447e6a.akpm@linux-foundation.org> <20110208.134421.39185637.davem@davemloft.net> <4D51BFCE.2070405@msgid.danisch.de> <20110208.143046.246534138.davem@davemloft.net> <20110208224411.GA9674@electric-eye.fr.zoreil.com> <4D51CAE8.6070706@msgid.danisch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Hadmut Danisch <hadmut@danisch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57945 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755804Ab1BHXwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 18:52:46 -0500
Content-Disposition: inline
In-Reply-To: <4D51CAE8.6070706@msgid.danisch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hadmut Danisch <hadmut@danisch.de> :
[...]
> Since Linux machines can - in contrast to Windows desktops and cisco
> routers - can be a host and a router at the same time, even on the same
> interface (i.e. use a autoconf IPv6 address as a host and an fe80::
> address as a router address).
> 
> So I'd consider this in a different way. From my point of view the
> decision between host and router must be done per assigned IPv6 address
> (or address range) and not per IPv6 interface.

o^O

Afaik networking does not operate this way in the kernel. Really.

May I suggest you to have some sleep and see how your (dhcpv6 enabled ?)
DSL router can be convinced to collaborate with the existing tools under
Linux _without_ modifications ?

-- 
Ueimor
