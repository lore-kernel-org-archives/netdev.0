From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 3/4] ixgbe: Fix link capabilities during
 adapter resets
Date: Tue, 30 Jun 2009 19:50:30 -0700 (PDT)
Message-ID: <20090630.195030.142473885.davem@davemloft.net>
References: <20090630214349.17464.25370.stgit@localhost.localdomain>
	<20090630214436.17464.65010.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, stable@kernel.org,
	mallikarjuna.chilakala@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54725
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755727AbZGACuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 22:50:25 -0400
In-Reply-To: <20090630214436.17464.65010.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 30 Jun 2009 14:44:36 -0700

> From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> 
> Adapter link advertisement capabilities were not persistent during
> adapter resets. While configuring multispeed fiber link check for
> phy autoneg_advertised settings before overwriting with default
> link capabilities
> 
> Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
