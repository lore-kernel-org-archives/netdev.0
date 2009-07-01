From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/4] ixgbe: Fix device capabilities of 82599
 single speed fiber NICs.
Date: Tue, 30 Jun 2009 19:50:23 -0700 (PDT)
Message-ID: <20090630.195023.75397236.davem@davemloft.net>
References: <20090630214349.17464.25370.stgit@localhost.localdomain>
	<20090630214416.17464.72434.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, stable@kernel.org,
	mallikarjuna.chilakala@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54720
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755339AbZGACuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 22:50:17 -0400
In-Reply-To: <20090630214416.17464.72434.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 30 Jun 2009 14:44:16 -0700

> From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> 
> 82599 single speed fiber modules only support 10G/Full. Return
> proper device capabilities while querrying the adapter and error
> while changing device advertisement/speed/duplex capabilities.
> 
> Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
