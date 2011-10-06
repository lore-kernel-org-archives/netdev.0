From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/3] dcb: Use ifindex instead of ifname
Date: Thu, 06 Oct 2011 15:50:12 -0400 (EDT)
Message-ID: <20111006.155012.1825838109469418965.davem@davemloft.net>
References: <20111006185233.2781.80310.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59140 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759213Ab1JFTuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 15:50:17 -0400
In-Reply-To: <20111006185233.2781.80310.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Thu, 06 Oct 2011 11:52:33 -0700

> From: Mark Rustad <mark.d.rustad@intel.com>
> 
> Use ifindex instead of ifname in the DCB app ring. This makes for a smaller
> data structure and faster comparisons. It also avoids possible issues when
> a net device is renamed.
> 
> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
