From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/2] e1000e: workaround link issues on busy hub
 in half duplex on 82577/82578
Date: Wed, 13 Jan 2010 17:15:45 -0800 (PST)
Message-ID: <20100113.171545.171350675.davem@davemloft.net>
References: <20100113115248.23394.71869.stgit@localhost.localdomain>
	<20100113115307.23394.31.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58594
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754765Ab0ANBPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 20:15:36 -0500
In-Reply-To: <20100113115307.23394.31.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 13 Jan 2010 03:53:08 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> This patch removes a delay in hardware after every received packet allowing
> more time for transmitted packets to go out in between received packets in
> half duplex.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
