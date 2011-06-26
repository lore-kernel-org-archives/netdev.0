From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [RFC 18/72] ehea/ibm*: Move the IBM drivers
Date: Sun, 26 Jun 2011 10:37:01 +1000
Message-ID: <1309048621.32158.341.camel@pasglop>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1309010363-22750-19-git-send-email-jeffrey.t.kirsher@intel.com>
	 <4E05F320.1080202@hartkopp.net>  <201106251704.22561.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	Christoph Raisch <raisch@de.ibm.com>,
	Alfred Arnold <alfred.arnold@lancom.de>,
	Santiago Leon <santil@linux.vnet.ibm.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51792 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752075Ab1FZAh7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 20:37:59 -0400
In-Reply-To: <201106251704.22561.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-06-25 at 17:04 +0200, Arnd Bergmann wrote:
> You can probably rename to just emac now, since the "old" emac driver
> has been gone for some time.
> 
> The "new" part of the name does not refer to the hardware, just to
> the driver.

Right. Agreed.

Cheers,
Ben.


