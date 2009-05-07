From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 5/5] ixgbe: Typecase '1' for 64 bit shift
Date: Thu, 07 May 2009 14:56:30 -0700 (PDT)
Message-ID: <20090507.145630.37703623.davem@davemloft.net>
References: <20090507203854.19886.54737.stgit@localhost.localdomain>
	<20090507204015.19886.92292.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, shannon.nelson@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34463
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755005AbZEGV4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 17:56:34 -0400
In-Reply-To: <20090507204015.19886.92292.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 07 May 2009 13:40:15 -0700

> Make sure we don't get any sign-extend issues when we shift a 1
> into bit 31.
> 
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
