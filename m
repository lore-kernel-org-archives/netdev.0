From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 0/4] d80211: fix receiving
Date: Mon,  3 Jul 2006 19:24:06 +0200 (CEST)
Message-ID: <20060703192335.935001000.midnight@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:2223 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1751155AbWGCRWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2006 13:22:33 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series fixes receiving when multiple virtual interfaces are
active.

It is also available in a 'devel' branch of git tree at
git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git

-- 
Jiri Benc
SUSE Labs
