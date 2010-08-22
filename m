From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-2.6 0/6] be2net: some bug fixes for net-2.6
Date: Sun, 22 Aug 2010 14:59:37 +0530
Message-ID: <20100822092928.GA22387@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:2880 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752060Ab0HVJ3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 05:29:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patchset includes bug fixes for net-2.6. Please apply.

1/5: fix net-snmp error because of wrong packet stats
2/6: fix a bug in UE detection logic
3/6: remove a BUG_ON in be_cmds.c
4/6: fix to dynamically generate MAC Address for VFs
5/6: display statistics for packets received due to internal switching in ASIC.
6/6: fix to get RxQ IDs 0 and 1.

Thanks
-Ajit
