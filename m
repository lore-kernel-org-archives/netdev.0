From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 0/6] d80211: add more IEEE802.11e/WMM support
Date: Thu, 14 Dec 2006 12:01:48 +0800
Message-ID: <20061214040148.GA10633@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:31539 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750925AbWLNENs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 23:13:48 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The following patches add more advanced IEEE802.11e/WMM features for d80211.
Your comments are welcome.


[PATCH 1/6] d80211: add IEEE802.11e/WMM MLMEs, Status Code and Reason Code
[PATCH 2/6] d80211: create "wifi.h" to define WIFI OUIs
[PATCH 3/6] d80211: fix classify_1d() priority selection
[PATCH 4/6] d80211: add IEEE802.11e/WMM Traffic Stream (TS) Management support
[PATCH 5/6] d80211: add IEEE 802.11e Direct Link Setup (DLS) support
[PATCH 6/6] d80211: add sysfs interface for QoS functions


Thanks,
-yi
