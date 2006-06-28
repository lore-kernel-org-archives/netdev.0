From: David Miller <davem@davemloft.net>
Subject: RDMA will be reverted
Date: Wed, 28 Jun 2006 00:07:15 -0700 (PDT)
Message-ID: <20060628.000715.95062023.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:56254
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423193AbWF1HHX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 03:07:23 -0400
To: rolandd@cisco.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Roland, there is no way in the world we would have let support for
RDMA into the kernel tree had we seen and reviewed it on netdev.  I've
discussed this with Andrew Morton, and we'd like you to please revert
all of the RDMA code from Linus's tree immedialtely.

Folks are well aware how against RDMA and TOE type schemes the Linux
networking developers are.  So the fact that none of these RDMA
changes went up for review on netdev strikes me as just a little bit
more than suspicious.

Please do not do this again, thank you.
