From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 20/20] ixgbe: rewrite ethtool test to use
 standard config functions
Date: Thu, 19 Aug 2010 16:47:32 -0700 (PDT)
Message-ID: <20100819.164732.242155767.davem@davemloft.net>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
	<20100819234052.10335.57519.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60478
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754067Ab0HSXrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:47:15 -0400
In-Reply-To: <20100819234052.10335.57519.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Aug 2010 16:40:54 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change makes it so that the ethtool loopback test uses the standard
> ring configuration and allocation functions.  As a result the loopback test
> will be much more effective at testing core driver functionality.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
