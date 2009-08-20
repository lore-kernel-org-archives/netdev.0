From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [V3] net: add Xilinx emac lite device driver
Date: Thu, 20 Aug 2009 02:52:26 -0700 (PDT)
Message-ID: <20090820.025226.26907868.davem@davemloft.net>
References: <20090820094956.02DFC45004F@mail96-dub.bigfish.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	grant.likely@secretlab.ca, jwboyer@linux.vnet.ibm.com,
	john.williams@petalogix.com, michal.simek@petalogix.com,
	sadanan@xilinx.com
To: john.linn@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41756
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753182AbZHTJwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 05:52:14 -0400
In-Reply-To: <20090820094956.02DFC45004F@mail96-dub.bigfish.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Linn <john.linn@xilinx.com>
Date: Thu, 20 Aug 2009 03:49:51 -0600

> This patch adds support for the Xilinx Ethernet Lite device.  The
> soft logic core from Xilinx is typically used on Virtex and Spartan
> designs attached to either a PowerPC or a Microblaze processor.
> 
> Signed-off-by: Sadanand M <sadanan@xilinx.com>
> Signed-off-by: John Linn <john.linn@xilinx.com>

Applied, thanks.
