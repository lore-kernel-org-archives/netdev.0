From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/3] igb/ixgbe: add IPV6_CSUM support to
 vlan_features
Date: Wed, 26 Aug 2009 15:38:25 -0700 (PDT)
Message-ID: <20090826.153825.86015346.davem@davemloft.net>
References: <20090825144709.15560.28811.stgit@localhost.localdomain>
	<20090825144750.15560.4450.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51690
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754223AbZHZWiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 18:38:12 -0400
In-Reply-To: <20090825144750.15560.4450.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 25 Aug 2009 07:47:50 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> We were already exporting TSO6 to the vlan, but we weren't exporting the
> checksum support for IPV6 which was causing warning messages to be
> displayed when doing IPv6 TSO over a vlan.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
