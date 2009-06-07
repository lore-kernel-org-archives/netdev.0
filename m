From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 01/10] ixgbe: use rx_buffer_info->dma instead
 of nr_frags to determine skb unmap
Date: Sun, 07 Jun 2009 06:15:43 -0700 (PDT)
Message-ID: <20090607.061543.03259427.davem@davemloft.net>
References: <20090605015948.8468.25862.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42362
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753748AbZFGNPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2009 09:15:42 -0400
In-Reply-To: <20090605015948.8468.25862.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


All 10 patches applied, thanks!

The flow steering looks very exciting.
