From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.35-rc1] net-next: vmxnet3 fixes [3/5] Initialize
 link state at probe time
Date: Sun, 18 Jul 2010 14:49:27 -0700 (PDT)
Message-ID: <20100718.144927.216775656.davem@davemloft.net>
References: <alpine.LRH.2.00.1007150125240.25472@localhost.localdomain>
	<20100715.224435.45920963.davem@davemloft.net>
	<alpine.LRH.2.00.1007160050030.12503@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com
To: sbhatewara@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33839
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757321Ab0GRVtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jul 2010 17:49:11 -0400
In-Reply-To: <alpine.LRH.2.00.1007160050030.12503@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Fri, 16 Jul 2010 00:51:14 -0700 (PDT)

> Initialize vmxnet3 link state at probe time
> 
> This change initializes the state of link at the time when driver is
> loaded. The ethtool output for 'link detected' and 'link speed'
> is thus valid even before the interface is brought up.
> 
> Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>

Applied.

I'm still (patiently) waiting for the formal resubmission of patch #4
so I can also then apply patch #5.  Please post it at your next
possible convenience.

Thanks.
