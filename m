From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 43/75] spider-net: declare MODULE_FIRMWARE
Date: Tue, 10 Nov 2009 20:35:22 -0800 (PST)
Message-ID: <20091110.203522.41630656.davem@davemloft.net>
References: <1257630907.15927.445.camel@localhost>
	<200911091258.13989.jens@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, kou.ishizaki@toshiba.co.jp, jens@de.ibm.com,
	netdev@vger.kernel.org, arnd@arndb.de
To: jens@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49040
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756691AbZKKEez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 23:34:55 -0500
In-Reply-To: <200911091258.13989.jens@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jens Osterkamp <jens@linux.vnet.ibm.com>
Date: Mon, 9 Nov 2009 12:58:13 +0100

> In spider_net, the filesystem is checked for a valid firmware first, if it 
> does not exist, the firmware is taken from the device tree (which is the 
> default case).
> 
> Do you expect this behaviour to cause problems together with MODULE_FIRMWARE ?

I think it should be OK.
