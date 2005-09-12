From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.13 0/16] implement ETHTOOL_GPERMADDR support for a number of drivers
Date: Mon, 12 Sep 2005 10:48:53 -0400
Message-ID: <09122005104853.31717@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, Jon_Wetzel@Dell.com, john.ronciak@intel.com,
	ganesh.venkatesan@intel.com, cramerj@intel.com,
	jesse.brandeburg@intel.com, ayyappan.veeraiyan@intel.com,
	mchan@broadcom.com, davem@davemloft.net, p_gortmaker@yahoo.com,
	tsbogend@alpha.franken.de, romieu@fr.zoreil.com,
	shemminger@osdl.org, rl@hellgate.ch
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751372AbVILO77@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A collection of patches which add support for ETHTOOL_GPERMADDR to
the following drivers: 3c59x, 8139cp, 8139too, b44, bnx2, e1000,
e100, forcedeth, ixgb, ne2k-pci, pcnet32, r8169, skge, sundance,
tg3, via-rhine.

I apologize for all the small patches, but I wanted to trim the cc:
lists appropriately for each driver.
