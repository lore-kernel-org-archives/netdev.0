From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/3] igb: add support for set_rx_mode
 netdevice operation
Date: Thu, 03 Sep 2009 20:07:33 -0700 (PDT)
Message-ID: <20090903.200733.186991702.davem@davemloft.net>
References: <20090904004828.14537.72187.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51002
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932720AbZIDDHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:07:18 -0400
In-Reply-To: <20090904004828.14537.72187.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 03 Sep 2009 17:48:56 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch adds support for the set_rx_mode netdevice operation so that igb
> can better support multiple unicast addresses.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
