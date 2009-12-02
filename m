From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/9] e1000e: provide family-specific
 functions to manage VLAN filter arrays
Date: Wed, 02 Dec 2009 00:37:36 -0800 (PST)
Message-ID: <20091202.003736.69381561.davem@davemloft.net>
References: <20091202014641.396.57708.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53938
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754459AbZLBIha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 03:37:30 -0500
In-Reply-To: <20091202014641.396.57708.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 01 Dec 2009 17:46:43 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> The two MAC-families that have VLAN filter table register arrays manage
> each a bit differently from one another, so provide family-specific
> functions for managing the register arrays and function pointers to access
> the appropriate function.  Also make sure attempts to access these
> register arrays are not done on parts not supporting that feature.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
