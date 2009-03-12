From: Christer Weinigel <christer@weinigel.se>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 18:52:10 +0100
Message-ID: <49B94BCA.6090309@weinigel.se>
References: <49B91A7B.7050303@weinigel.se>	<20090312151211.GB24995@hmsreliant.think-freely.org>	<49B93777.7030202@weinigel.se> <20090312.104345.68580544.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, shemminger@vyatta.com,
	s.hauer@pengutronix.de, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2-1-3-15a.ens.sth.bostream.se ([82.182.31.214]:59056 "EHLO
	zoo.weinigel.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754074AbZCLRwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 13:52:15 -0400
In-Reply-To: <20090312.104345.68580544.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Just about every single distribution has to build a initrd
> that has to be able to setup a network, and have the necessary
> infrastructure to access things over NFS in order to implement
> their installer.
> 
> You can start with the debian installer, that's probably the
> easiest to hack on and extend.
> 
> Or you can just continue to list excuses, that might be easier.

Or I can keep patching the drivers, that's even easier.  No it's not 
something I expect to see in the official kernel, but who cares, I 
always have loads of debug patches that won't get into the official 
kernel either.  Keep the status quo.

   /Christer
