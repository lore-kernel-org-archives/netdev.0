From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2.6.11-rc3 0/5] bonding: bonding and related updates
Date: Fri, 11 Feb 2005 01:15:19 -0800
Message-ID: <200502110915.j1B9FKC0003633@death.nxdomain.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Some bonding updates.  The first two implement the
dev_set_mac_address business discussed earlier on netdev.  The rest are
some bonding documentation and message updates unrelated to the MAC
address changes.

	1/5 Move SIOCSIFHWADDR code into new function
	2/5 Update bonding to use previous as well as dev_set_mtu
	3/5 Fix a misleading warning message in bonding
	4/5 Update to Kconfig bonding description
	5/5 Update/rewrite of Documentation/networking/bonding.txt

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
