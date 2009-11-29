From: David Miller <davem@davemloft.net>
Subject: MERGE check, net-next-2.6...
Date: Sun, 29 Nov 2009 01:17:09 -0800 (PST)
Message-ID: <20091129.011709.11078985.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, linville@tuxdriver.com,
	amit@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42962
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754260AbZK2JRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 04:17:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I just merged net-2.6 into net-next-2.6, there were several
conflicts.

They happened in e1000e, ath9k, generic ieee80211, and the
netxen driver.

Please check my work and send any necessary fixes.

Thanks!
