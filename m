From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: netif_device_attach/detach should start/stop all
 queues
Date: Sat, 11 Apr 2009 01:44:10 -0700 (PDT)
Message-ID: <20090411.014410.67341581.davem@davemloft.net>
References: <20090408231519.8537.79219.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42490
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751970AbZDKIoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 04:44:20 -0400
In-Reply-To: <20090408231519.8537.79219.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 08 Apr 2009 16:15:22 -0700

> Currently netif_device_attach/detach are only stopping one queue.  They
> should be starting and stopping all the queues on a given device.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
