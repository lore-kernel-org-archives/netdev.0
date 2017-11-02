From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/4] Updates for samples/pktgen
Date: Thu, 02 Nov 2017 14:20:20 +0900 (KST)
Message-ID: <20171102.142020.275473805803540023.davem@davemloft.net>
References: <150953283424.29671.6809291616813585256.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robert@herjulf.se, robert.hu@intel.com,
        pabeni@redhat.com, kafai@fb.com, tariqt@mellanox.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42156 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751245AbdKBFUY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 01:20:24 -0400
In-Reply-To: <150953283424.29671.6809291616813585256.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 01 Nov 2017 11:41:04 +0100

> This patchset updates samples/pktgen and synchronize with changes
> maintained in https://github.com/netoptimizer/network-testing/
> 
> Features wise Robert Hoo <robert.hu@intel.com> added support for
> detecting and determining dev NUMA node IRQs, and added a new script
> named pktgen_sample06_numa_awared_queue_irq_affinity.sh that use these
> features.
> 
> Cleanup remove last of the old sample files, as IPv6 is covered by
> existing sample code.

Series applied, thanks Jesper.
