From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbevf: declare functions as static
Date: Tue, 05 Oct 2010 20:14:47 -0700 (PDT)
Message-ID: <20101005.201447.104066172.davem@davemloft.net>
References: <20101005231030.24410.47680.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	shemminger@vyatta.com, emil.s.tantilov@intel.com,
	greg.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48137
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756680Ab0JFDO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 23:14:26 -0400
In-Reply-To: <20101005231030.24410.47680.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 05 Oct 2010 16:11:30 -0700

> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> Following patch fixes warnings reported by `make namespacecheck`
> 
> Reported by Stephen Hemminger
> 
> CC: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Acked-by: Greg Rose <greg.v.rose@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
