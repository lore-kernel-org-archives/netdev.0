From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] ixgbe: fix setting of promisc mode
 when using mac-vlans
Date: Thu, 13 May 2010 21:09:19 -0700 (PDT)
Message-ID: <20100513.210919.02274972.davem@davemloft.net>
References: <20100514033233.30716.30144.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, emil.s.tantilov@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43826
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750768Ab0ENEJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 00:09:12 -0400
In-Reply-To: <20100514033233.30716.30144.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 13 May 2010 20:33:00 -0700

> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> Introduce uc_set_promisc flag to fix enabling of promisc mode
> when exceeding the number of supported RAR entries.
> 
> Issue discovered by Ben Greear when using mac-vlans.
> 
> Reported-by: Ben Greear <greearb@candelatech.com>
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
