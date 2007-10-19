From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 0/8] [MV643XX_ETH] Add Orion support, and assorted cleanups
Date: Fri, 19 Oct 2007 04:09:32 +0200
Message-ID: <20071019020932.GB16037@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Manas Saksena <msaksena@marvell.com>, netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:43976 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933569AbXJSCJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 22:09:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series adds support for the Orion's ethernet MAC
(which is the same MAC as in the Discovery 643xx) to the mv643xx_eth
driver, and performs various random cleanups all over the driver.

Patches 1-3 are cleanups necessary to be able to support Orion.

Patch 4 enables mv643xx_eth for ARCH_ORION.

Patches 5-8 are more cleanups.
