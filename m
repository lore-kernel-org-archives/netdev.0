From: Zhu Yi <yi.zhu@intel.com>
Subject: ipw2200 driver updates
Date: Mon, 21 Aug 2006 11:36:40 +0800
Message-ID: <20060821033640.GA5315@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:15190 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932563AbWHUDif (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:38:35 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

Here are some patches for ipw2100 and ipw2200 driver. Please apply.

[PATCH 01/14] ipw2200: always enable frequently used debugging code
[PATCH 02/14] ipw2200: SIOCGIWFREQ ioctl returns frequency rather than channel
[PATCH 03/14] ipw2200: ipw_wx_set_essid fix
[PATCH 04/14] ipw2200: Reassociate even if set the same essid.
[PATCH 05/14] ipw2200: remove unused struct ipw_rx_buffer
[PATCH 06/14] ipw2100: Make ipw2100 depends on known working platforms
[PATCH 07/14] ipw2200: Fix ipw2200 QOS parameters endian issue
[PATCH 08/14] ipw2200: remove the MAC timestamp present field from radiotap head
[PATCH 09/14] ipw2200: mark "iwconfig retry 255" as invalid
[PATCH 10/14] ipw2200: Fix kernel Oops if cmdlog debug is enabled
[PATCH 11/14] ipw2200: Add pci .shutdown handler
[PATCH 12/14] ipw2100: Fix deadlock detected by lockdep
[PATCH 13/14] ipw2200: enable wireless extension passive scan
[PATCH 14/14] Update version ipw2200 stamp to 1.1.4

Thanks,
-yi
