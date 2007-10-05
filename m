From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.24] ip_gre: build fix
Date: Thu, 04 Oct 2007 17:54:58 -0700 (PDT)
Message-ID: <20071004.175458.65902078.davem@davemloft.net>
References: <47055FD6.5070801@intel.com>
	<20071004.151108.82373575.davem@davemloft.net>
	<20071004174738.00c64226@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36554
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757443AbXJEAy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 20:54:59 -0400
In-Reply-To: <20071004174738.00c64226@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 4 Oct 2007 17:47:38 -0700

> IPGRE only uses header_ops in the case of CONFIG_NET_IPGRE_BROADCAST.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied, thanks Stephen.
