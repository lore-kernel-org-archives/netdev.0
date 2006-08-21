From: Zhu Yi <yi.zhu@intel.com>
Subject: ipw2200 driver updates
Date: Mon, 21 Aug 2006 11:32:03 +0800
Message-ID: <20060821033203.GA4743@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38492 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932539AbWHUDd6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:33:58 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

Below are some ieee80211 patches I'd like to submit upstream. Please
apply.

[PATCH 1/7] ieee80211: Fix header->qos_ctl endian issue
[PATCH 2/7] ieee80211: remove ieee80211_tx() is_queue_full warning
[PATCH 3/7] ieee80211: TKIP and CCMP replay check rework
[PATCH 4/7] ieee80211: Add IEEE80211_API_VERSION macro
[PATCH 5/7] ieee80211: export symbol ieee80211_api_version
[PATCH 6/7] ieee80211: Fix TKIP and WEP decryption error on SMP machines
[PATCH 7/7] ieee80211: Workaround malformed 802.11 frames from AP

Thanks,
-yi
