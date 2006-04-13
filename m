From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 0/6] ieee80211 updates
Date: Thu, 13 Apr 2006 17:16:54 +0800
Message-ID: <20060413091654.GA28634@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr19.intel.com ([134.134.136.18]:973 "EHLO
	orsfmr004.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751231AbWDMJX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:23:58 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Here are some patches for ieee80211, please apply.


[PATCH 1/6] ieee80211: Fix TKIP MIC calculation for QoS frames
[PATCH 2/6] ieee80211: Fix TX code doesn't enable QoS when using WPA + QoS
[PATCH 3/6] ieee80211: export list of bit rates with standard WEXT procdures
[PATCH 4/6] ieee80211: remove unnecessary CONFIG_WIRELESS_EXT checking
[PATCH 5/6] ieee80211: replace debug IEEE80211_WARNING with each own debug macro
[PATCH 6/6] ieee80211: update version stamp to 1.1.13

Thanks,
-yi
