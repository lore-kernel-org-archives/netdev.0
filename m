From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 0/4] mv643xx_eth: more cleanups
Date: Wed, 19 Mar 2008 08:48:36 +0100
Message-ID: <20080319074836.GA5010@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Saeed Bishara <saeed@marvell.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:47620 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758772AbYCSUR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 16:17:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series consists of a couple more mv643xx_eth cleanups, and:
- goes on top of the 7-patch series '[MV643XX_ETH] various cleanups'
  posted earlier (http://marc.info/?l=linux-netdev&m=120578137313014&w=2)
- supercedes the 5-patch series '[MV643XX_ETH] more cleanups' posted
  earlier (http://marc.info/?l=linux-netdev&m=120578462019528&w=2)
- depends on http://marc.info/?l=linux-arch&m=120488703904416&w=2
  (which will be submitted via the ARM tree.)

I pulled out the SMI sharing patch (4/5), since that needs a bit
more testing.
