From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/2] Bonding device changes for later RTNL_LINK interface
Date: Wed, 10 Jun 2009 09:39:55 -0700
Message-ID: <20090610163955.266850193@vyatta.com>
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:34297 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752414AbZFJRcf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2009 13:32:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am working on a RTNL_LINK interface for bonding. These are
small internal changes that making doing that easier. Plus they
make bonding devices more like other usages.

-- 

