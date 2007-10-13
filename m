From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: Bonding support for eth1394?
Date: Sat, 13 Oct 2007 20:03:42 +0200
Message-ID: <4711087E.1050005@s5r6.in-berlin.de>
References: <FFB081ED-646B-489D-8836-FBA619A57E3E@gmail.com>	<47106EDE.1090601@s5r6.in-berlin.de> <adair5bm3jf.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Karl Svec <karlsvec@gmail.com>,
	linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:40055 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762424AbXJMSEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2007 14:04:08 -0400
In-Reply-To: <adair5bm3jf.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
> There are a few changes to the bonding driver pending that will add
> support for bonding IP-over-InfiniBand interfaces.  IPoIB also cannot
> change its HW address, so the patches address that issue.
> 
> Once those patches land, bonding eth1394 interfaces may "just work".

Sounds promising.  I will keep an eye on it.
-- 
Stefan Richter
-=====-=-=== =-=- -==-=
http://arcgraph.de/sr/
