From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add the FCoE Initialization Protocol ethertype
Date: Fri, 01 May 2009 15:04:54 -0700 (PDT)
Message-ID: <20090501.150454.224636608.davem@davemloft.net>
References: <20090501185532.14602.21059.stgit@fritz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: robert.w.love@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45892
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751913AbZEAWFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 18:05:00 -0400
In-Reply-To: <20090501185532.14602.21059.stgit@fritz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Love <robert.w.love@intel.com>
Date: Fri, 01 May 2009 11:55:32 -0700

> FIP is the FCoE Initialization Protocol and this patch
> adds the protocol ethertype to the kernel's list of
> ethertypes.
> 
> Signed-off-by: Joe Eykholt <jeykholt@cisco.com>
> Signed-off-by: Robert Love <robert.w.love@intel.com>

You can add this value, when you add the protocol implementation
into the upstream sources.
