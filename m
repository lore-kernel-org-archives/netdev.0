From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 0/14] d80211: pull request
Date: Wed, 13 Dec 2006 17:41:35 +0100 (CET)
Message-ID: <20061213174109.005697000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:57258 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965033AbWLMRIx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 12:08:53 -0500
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from
git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git up
to obtain following patches:

David Kimdon:
      d80211: allow for hardware crypto of default keys
      d80211: set default_wep_only dynamically
      d80211: fix potential interface name overflow
      d80211: fix potential invalid array index returning key information
      d80211: remove unused references to sub interface data
      d80211: fix invalid check for sub interface type AP
      d80211: do not pass an invalid key index to set_key()

Jiri Benc:
      Merge branch 'from-john'

Michael Buesch:
      d80211: Fix errorcode in ieee80211_update_hw

Michael Wu:
      d80211: remove pkt_type/pkt_probe_resp
      d80211: move 802.11 defines to linux/ieee80211.h
      d80211: merge d80211_shared.h into d80211.h
      d80211: merge d80211_mgmt.h into linux/ieee80211.h
      d80211: move d80211_common.h to net/d80211

Mohamed Abbas:
      d80211: add mising sta_info_put function


-- 
Jiri Benc
SUSE Labs
