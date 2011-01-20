From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: cleanup unused macros in net directory
Date: Wed, 19 Jan 2011 23:20:24 -0800 (PST)
Message-ID: <20110119.232024.85405176.davem@davemloft.net>
References: <4D300728.8030402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjur.brandeland@stericsson.com, andy.grover@oracle.com,
	ericvh@gmail.com, jvrao@us.ibm.com,
	aneesh.kumar@linux.vnet.ibm.com, joe@perches.com,
	xiaosuo@gmail.com, eric.dumazet@gmail.com, jpirko@redhat.com,
	nhorman@tuxdriver.com, pebolle@tiscali.nl, jkosina@suse.cz,
	arnd@arndb.de, netdev@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net, rds-devel@oss.oracle.com
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58441
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751701Ab1ATHTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 02:19:51 -0500
In-Reply-To: <4D300728.8030402@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Fri, 14 Jan 2011 16:19:52 +0800

> 
> Clean up some unused macros in net/*.
> 1. be left for code change. e.g. PGV_FROM_VMALLOC, PGV_FROM_VMALLOC, KMEM_SAFETYZONE.
> 2. never be used since introduced to kernel.
>    e.g. P9_RDMA_MAX_SGE, UTIL_CTRL_PKT_SIZE.
> 
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Applied, thanks.
