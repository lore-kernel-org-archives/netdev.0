From: Hadmut Danisch <hadmut@danisch.de>
Subject: Re: [Bugme-new] [Bug 28282] New: forwarding turns autoconfiguration
 off
Date: Thu, 24 Mar 2011 16:07:10 +0100
Message-ID: <4D8B5E1E.6060608@msgid.danisch.de>
References: <20110208133408.7d447e6a.akpm@linux-foundation.org> <20110208.134421.39185637.davem@davemloft.net> <4D51BFCE.2070405@msgid.danisch.de> <20110208.143046.246534138.davem@davemloft.net> <20110208224411.GA9674@electric-eye.fr.zoreil.com> <20110208234753.48abd902.billfink@mindspring.com> <20110209074221.GA9790@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Bill Fink <billfink@mindspring.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sklave3.rackland.de ([212.86.200.186]:53325 "EHLO
	sklave3.rackland.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518Ab1CXPPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 11:15:30 -0400
In-Reply-To: <20110209074221.GA9790@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

since the discussion seems to have completely died, just allow me a
simple question:


How would I configure a Linux machine to accept ipv6 prefix ads (because
they are dynamically assigned and advertised by my router) and to work
as a VPN tunnel end?


Remember: Linux does not allow autoconfiguration and routing at the same
time, without any good reason. The only reason I've seen so far is that
the Terminology in an RFC vaguely distinguishes between router machines
and nodes.


If you believe that Linux is correct here the way it is, just tell me
how to solve that problem with Linux.


best regards
Hadmut

