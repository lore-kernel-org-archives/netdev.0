From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 00/77] Convert most of the rest of the devices to net_device_ops
Date: Fri, 20 Mar 2009 22:35:27 -0700
Message-ID: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36459 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759564AbZCUFsI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series against net-next-2.6 fixes most of the remaining
network devices to use net_device_ops. ALL ARE COMPILE TESTED ONLY.

-- 

