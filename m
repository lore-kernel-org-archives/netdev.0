From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3 0/8] Fix Tunnel features and enable GSO
 partial for several drivers
Date: Tue, 03 May 2016 16:01:48 -0400 (EDT)
Message-ID: <20160503.160148.379958150463085852.davem@davemloft.net>
References: <20160502162828.11809.92444.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: talal@mellanox.com, netdev@vger.kernel.org,
	michael.chan@broadcom.com, alexander.duyck@gmail.com,
	galp@mellanox.com, ogerlitz@mellanox.com, eranbe@mellanox.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52459 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756177AbcECUBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 16:01:50 -0400
In-Reply-To: <20160502162828.11809.92444.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Mon, 02 May 2016 09:38:06 -0700

> v3: Moved 2 patches into series for net as they were generic fixes.
>     Added patch to disable GSO partial if frame is less than 2x size of MSS

I'll therefore apply this series after my next net --> net-next merge.

Thanks.
