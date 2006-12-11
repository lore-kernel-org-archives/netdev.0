From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH  v3 13/13] Kconfig/Makefile
Date: Sun, 10 Dec 2006 21:02:20 -0800
Message-ID: <adaac1v2ffn.fsf@cisco.com>
References: <20061210223244.27166.36192.stgit@dell3.ogc.int>
	<20061210223916.27166.82130.stgit@dell3.ogc.int>
	<20061210145602.d2a8bb98.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Wise <swise@opengridcomputing.com>, netdev@vger.kernel.org,
	openib-general@openib.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:21851 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762451AbWLKFCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 00:02:25 -0500
To: Randy Dunlap <randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > +++ b/drivers/infiniband/hw/cxgb3/locking.txt

 > Should be in Documentation/infiniband/.
 > Docs go in the Documentation/ dir, not in drivers/ dir.

Or put it in a comment in the appropriate header, if you want to keep
it close to the driver source...
