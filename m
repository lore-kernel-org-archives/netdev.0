From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/5] ixgbe: set queue0 for srrctl
 configuration correctly for DCB
Date: Thu, 07 May 2009 14:56:07 -0700 (PDT)
Message-ID: <20090507.145607.252281114.davem@davemloft.net>
References: <20090507203854.19886.54737.stgit@localhost.localdomain>
	<20090507203915.19886.76171.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34450
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753356AbZEGV4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 17:56:11 -0400
In-Reply-To: <20090507203915.19886.76171.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 07 May 2009 13:39:16 -0700

> The current configuration is not setting queue 0 correctly for DCB
> configurations.  As a result unconfigured queues are being used to setup
> the SRRCTL register rx buffer len sizes.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
