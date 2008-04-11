From: Joonwoo Park <joonwpark81@gmail.com>
Subject: [PATCH 0/5]: [VLAN] fixes for PACKET
Date: Fri, 11 Apr 2008 18:25:23 +0900
Message-ID: <20080411092523.GA6873@tp64>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jeff@garzik.org, netdev@vger.kernel.org
To: kaber@trash.net, auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:16450 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759211AbYDKJZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 05:25:35 -0400
Received: by wa-out-1112.google.com with SMTP id m16so340197waf.23
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 02:25:35 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
This patchset is the v3 for resolving the issue about VLAN & PACKET.
It contains some cleanups for vlan as well.

Related previous discussions are below:
http://bugzilla.kernel.org/show_bug.cgi?id=8218
http://thread.gmane.org/gmane.linux.drivers.e1000.devel/2587
http://thread.gmane.org/gmane.linux.network/88488

[PATCH 1/5] [VLAN]: Unclassified vlan packet
[PATCH 2/5] [VLAN]: Add vlan tag into PACKET_AUXDATA
[PATCH 3/5] [VLAN]: Use is_vlan_dev()
[PATCH 4/5] [E1000]: [VLAN] Turn off the HW vlan filter if promisc
[PATCH 5/5] [E1000e]: [VLAN] Turn off the HW vlan filter if promisc

Thanks Patrick for the suggestions.

Please review and consider applying.

Thanks,
Joonwoo

