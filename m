From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 4/7] ixgbe: always enable vlan strip/insert
 when DCB is enabled
Date: Tue, 18 May 2010 19:44:49 -0700 (PDT)
Message-ID: <20100518.194449.106788807.davem@davemloft.net>
References: <20100519020003.18654.94899.stgit@localhost.localdomain>
	<20100519020008.18654.36543.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, yi.zou@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46542
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754376Ab0ESCok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 22:44:40 -0400
In-Reply-To: <20100519020008.18654.36543.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 18 May 2010 19:00:08 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> when DCB mode is on, we want the HW VLAN stripping to be always enabled.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
