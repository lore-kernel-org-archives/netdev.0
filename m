From: Ulrich Kunitz <kune@deine-taler.de>
Subject: [PATCH] zd1211rw: six urgent upstream fixes
Date: Tue, 01 Aug 2006 23:43:29 +0200
Message-ID: <1154468615618-git-send-email-kune@deine-taler.de>
Reply-To: Ulrich Kunitz <kune@deine-taler.de>
Cc: netdev@vger.kernel.org, dsd@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:26052 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1751051AbWHAVng (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 17:43:36 -0400
To: linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here are six fixes for the zd1211rw driver.

They fix
 - radiotap issues for the monitor mode
 - WEP encryption
 - an endianess problem in the rx path
 - reassociation after disassociation be the AP

If possible these patches should be included in 2.6.18

-- Uli
