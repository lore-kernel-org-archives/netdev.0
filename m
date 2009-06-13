From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/9] Bonding patches for 2.6.31
Date: Fri, 12 Jun 2009 22:02:43 -0700
Message-ID: <20090613050243.100086546@vyatta.com>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Jay Vosburg <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49241 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754161AbZFMFGU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Jun 2009 01:06:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I started implementing a netlink interface to bonding, and quickly
saw lots of things that need to be cleaned up first.
-- 

