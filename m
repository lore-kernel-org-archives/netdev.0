From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 8/9] e1000e: PHY type cleanups in
 e1000e_check_downshift()
Date: Wed, 02 Dec 2009 00:38:19 -0800 (PST)
Message-ID: <20091202.003819.186409219.davem@davemloft.net>
References: <20091202015250.592.56893.stgit@localhost.localdomain>
	<20091202015326.592.83129.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53974
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754754AbZLBIiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 03:38:13 -0500
In-Reply-To: <20091202015326.592.83129.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 01 Dec 2009 17:53:48 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Remove the case for 82577 because it does not support the ability to check
> for downshift.  Add case for e1000_phy_bm which can do this.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
