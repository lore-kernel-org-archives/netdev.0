From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/3] ixgbe: cleanup functions that should have
 been defined static
Date: Wed, 26 Aug 2009 15:38:19 -0700 (PDT)
Message-ID: <20090826.153819.205809521.davem@davemloft.net>
References: <20090825144709.15560.28811.stgit@localhost.localdomain>
	<20090825144731.15560.73592.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51685
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754218AbZHZWiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 18:38:05 -0400
In-Reply-To: <20090825144731.15560.73592.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 25 Aug 2009 07:47:32 -0700

> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> We have some ~40 functions that were being called out with 'make
> namespacecheck'.  This patch changes these functions to be static.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
