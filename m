From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 00/18] ipw2200 driver updates
Date: Thu, 13 Apr 2006 17:18:48 +0800
Message-ID: <20060413091848.GA28688@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr19.intel.com ([134.134.136.18]:17613 "EHLO
	orsfmr004.jf.intel.com") by vger.kernel.org with ESMTP
	id S964838AbWDMJZw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:25:52 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The following patches are ipw2200 driver recently update. Please apply.


[PATCH 01/18] ipw2200: Exponential averaging for signal and noise Level
[PATCH 02/18] ipw2200: Fix TX QoS enabled frames problem
[PATCH 03/18] ipw2200: generates a scan event after a scan has completed
[PATCH 04/18] ipw2200: add module_param support for antenna selection
[PATCH 05/18] ipw2200: fix compile warning when !CONFIG_IPW2200_DEBUG
[PATCH 06/18] ipw2200: Do not continue loading the firmware if kmalloc fails
[PATCH 07/18] ipw2200: turn off signal debug log
[PATCH 08/18] ipw2200: Set the 'fixed' flags in wext get_rate
[PATCH 09/18] ipw2200: Fix endian issues with v3.0 fw image format
[PATCH 10/18] README.ipw2200: rename CONFIG_IPW_DEBUG to CONFIG_IPW2200_DEBUG
[PATCH 11/18] ipw2200: Enable rtap interface for RF promiscuous mode while associated
[PATCH 12/18] ipw2200: version string rework
[PATCH 13/18] ipw2200: update version stamp to 1.1.2
[PATCH 14/18] ipw2200: rename CONFIG_IPW_QOS to CONFIG_IPW2200_QOS
[PATCH 15/18] wireless Kconfig add IPW2200_RADIOTAP
[PATCH 16/18] ipw2200: rename CONFIG_IEEE80211_RADIOTAP to CONFIG_IPW2200_RADIOTAP
[PATCH 17/18] ipw2200: remove priv->last_noise reference
[PATCH 18/18] ipw2200: Fix wpa_supplicant association problem


Thanks,
-yi
