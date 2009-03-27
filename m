From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 00/30] last of the x86 net_device_ops
Date: Thu, 26 Mar 2009 18:11:14 -0700
Message-ID: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:39784 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754618AbZC0BTz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:19:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This sequence of patches makes all network drivers in net-next
build on 32bit using net_device_ops. 
Ie. allmodconfig and !CONFIG_COMPAT_NET_DEV_OPS



