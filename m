From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/4] ixgbe: Fix SFP log messages
Date: Tue, 30 Jun 2009 19:50:15 -0700 (PDT)
Message-ID: <20090630.195015.139233327.davem@davemloft.net>
References: <20090630214349.17464.25370.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, stable@kernel.org,
	donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54715
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751622AbZGACuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 22:50:09 -0400
In-Reply-To: <20090630214349.17464.25370.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 30 Jun 2009 14:43:55 -0700

> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> We had a wide range of log messages for the same sort of SFP
> failure.  This patch makes them all more similar and less
> confusing along with converting them to dev_err.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
