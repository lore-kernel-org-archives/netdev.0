From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH 0/3] be2net: some bug fixes for net-2.6
Date: Wed, 25 Aug 2010 16:02:03 +0530
Message-ID: <20100825103153.GA15624@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:39153 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753110Ab0HYKb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 06:31:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patchset includes bug fixes for net-2.6. Please apply.

1/3: fix net-snmp error because of wrong packet stats
2/3: fix a bug in UE detection logic
3/3: remove a BUG_ON in be_cmds.c

Thanks
-Ajit
