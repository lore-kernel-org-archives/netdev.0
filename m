From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3 0/8] Fix Tunnel features and enable GSO
 partial for several drivers
Date: Wed, 04 May 2016 13:32:54 -0400 (EDT)
Message-ID: <20160504.133254.1371487366581805190.davem@davemloft.net>
References: <20160502162828.11809.92444.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: talal@mellanox.com, netdev@vger.kernel.org,
	michael.chan@broadcom.com, alexander.duyck@gmail.com,
	galp@mellanox.com, ogerlitz@mellanox.com, eranbe@mellanox.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40559 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754440AbcEDRdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 13:33:02 -0400
In-Reply-To: <20160502162828.11809.92444.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Mon, 02 May 2016 09:38:06 -0700

> This patch series is meant to allow us to get the best performance possible
> for Mellanox ConnectX-3/4 and Broadcom NetXtreme-C/E adapters in terms of
> VXLAN and GRE tunnels.

Series applied, thanks Alex.
