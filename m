From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/4] PCI VPD changes
Date: Thu, 04 Sep 2008 13:56:36 -0700
Message-ID: <20080904205636.130211321@vyatta.com>
References: <20080904205636.130211023@vyatta.com>
Cc: linux-pci@vger.kernel.org, netdev@vger.kernel.org
To: Jesse Barnes <jbarnes@virtuousgeek.org>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update sky2 to use new VPD access routines.
The patches are against netdev-2.6 upstream-next branch,
and assume PCI changes submitted already.

-- 
