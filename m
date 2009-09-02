From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [V3] net: add Xilinx emac lite device driver
Date: Tue, 01 Sep 2009 17:51:58 -0700 (PDT)
Message-ID: <20090901.175158.133228373.davem@davemloft.net>
References: <20090820094956.02DFC45004F@mail96-dub.bigfish.com>
	<20090820.025226.26907868.davem@davemloft.net>
	<4A9BCDB4.8040406@petalogix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.linn@xilinx.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	grant.likely@secretlab.ca, jwboyer@linux.vnet.ibm.com,
	john.williams@petalogix.com, sadanan@xilinx.com
To: michal.simek@petalogix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35994
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755426AbZIBAvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 20:51:44 -0400
In-Reply-To: <4A9BCDB4.8040406@petalogix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Simek <michal.simek@petalogix.com>
Date: Mon, 31 Aug 2009 15:18:44 +0200

> I see that John's patch has wrong file permission
> -rwxr-xr-x 	xilinx_emaclite.c
 ...
> should be 644.
> 
> Please fix it in your repo.

Done, thanks!
