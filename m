From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 07:05:54 -0700 (PDT)
Message-ID: <20090312.070554.96115441.davem@davemloft.net>
References: <1236738549-16703-1-git-send-email-yanok@emcraft.com>
	<20090310211841.388619ca@nehalam>
	<F884D8C3-E35B-4239-8D72-165EE528FCAC@prograde.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, wd@denx.de, dzu@denx.de
To: mboards@prograde.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33264
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754169AbZCLOGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 10:06:08 -0400
In-Reply-To: <F884D8C3-E35B-4239-8D72-165EE528FCAC@prograde.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Cashwell <mboards@prograde.net>
Date: Thu, 12 Mar 2009 09:41:38 -0400

> I'm confused by this. If I'm NFS-booting the board then how do I get
> to those userland tools if I don't have a valid MAC address in place
> to do the root mount?

Initial ramdisk.
