From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: IPv6 multicast bind(), esp. v4-mapped addresses
Date: Wed, 10 Dec 2008 09:22:55 +0200 (EET)
Message-ID: <alpine.LRH.2.00.0812100921290.12460@netcore.fi>
References: <alpine.LRH.2.00.0812050820380.28482@netcore.fi> <20081205.161117.109565135.yoshfuji@linux-ipv6.org> <alpine.LRH.2.00.0812050928340.28482@netcore.fi> <20081205.000322.147998414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:60384 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754531AbYLJHXM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2008 02:23:12 -0500
In-Reply-To: <20081205.000322.147998414.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 5 Dec 2008, David Miller wrote:
> From what I've read, ipv4 mapped addresses are full of all kinds of
> tricky cases and issues.  And, given that, using ipv4 mapped address
> for ipv4 multicast is just asking for trouble in my opinion.

FWIW, I've communicated this issue to Java developers.  Let's hope 
they'll enhance their Java shim layer to avoid mapped addresses some 
time in the future:

http://mail.openjdk.java.net/pipermail/net-dev/2008-December/000494.html

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
