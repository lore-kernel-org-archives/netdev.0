From: Mikael Pettersson <mikpe@it.uu.se>
Subject: Re: [PATCH] Driver for IXP4xx built-in Ethernet ports
Date: Sat, 26 Apr 2008 12:16:38 +0200
Message-ID: <18451.262.785735.187086@harpo.it.uu.se>
References: <m3r6d05ucg.fsf@maximus.localdomain>
	<20080426092930.GG20657@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Halasa <khc@pm.waw.pl>, Jeff Garzik <jeff@garzik.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Martin Michlmayr <tbm@cyrius.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aun.it.uu.se ([130.238.12.36]:38271 "EHLO aun.it.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751282AbYDZKRC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Apr 2008 06:17:02 -0400
In-Reply-To: <20080426092930.GG20657@deprecation.cyrius.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Martin Michlmayr writes:
 > * Krzysztof Halasa <khc@pm.waw.pl> [2008-04-20 19:06]:
 > > Adds a driver for built-in IXP4xx Ethernet ports.
 > 
 > Are there any comments on this driver?  We've been using it for a
 > while now in Debian and it would be great see it in the mainline
 > kernel.

Same here. I've been using it on my IXP42x-based ARM box for
three months now, and it (a) hasn't caused a single problem of
any kind, and (b) is a massive improvement over having to deal
with Intel's IXP400 software and driver kit.
