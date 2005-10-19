From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.14-rc3 0/3] misc fixes/cleanups for sundance
Date: Tue, 18 Oct 2005 21:31:01 -0400
Message-ID: <10182005213101.12694@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932439AbVJSBeF@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just a little cleanup from me, and some fixes snarfed from the
ICPlus (chip vendor) version of the driver.

	-- Get rid of if (1) { ... } block in sundance_probe1

	-- Change PHY probing to start from MII address 0

	-- Expand the mask used when resetting the chip

Patches to follow...
