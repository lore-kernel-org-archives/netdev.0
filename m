From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 0/8] d80211: rate control modules locking and changing
Date: Mon,  2 Oct 2006 20:26:03 +0200 (CEST)
Message-ID: <20061002202530.235763132.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:39367 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S965240AbWJBSYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 14:24:52 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patch series fixes locking issues with rate control modules
and adds support for on-the-fly changing of the rate control algorithms.

During the work I discovered some bugs which are not exactly related to rate
controling; they are included in the series as well.

All patches are also available in the 'devel' branch of
git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git

 Jiri


-- 
Jiri Benc
SUSE Labs
