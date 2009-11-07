From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/3] ixgbe: Fix gso_max_size for 82599 when DCB
 is enabled
Date: Fri, 06 Nov 2009 20:34:01 -0800 (PST)
Message-ID: <20091106.203401.179384929.davem@davemloft.net>
References: <20091106225526.28063.83720.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, yi.zou@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46676
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760071AbZKGEdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 23:33:35 -0500
In-Reply-To: <20091106225526.28063.83720.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 06 Nov 2009 14:55:38 -0800

> From: Yi Zou <yi.zou@intel.com>
> 
> The 32k gso_max_size when DCB is enabled is for 82598 only, not for 82599.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
