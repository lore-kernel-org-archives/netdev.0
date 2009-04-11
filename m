From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ixgbe: Move the LED blink code to common, since
 82599 also uses it
Date: Sat, 11 Apr 2009 01:44:17 -0700 (PDT)
Message-ID: <20090411.014417.58835166.davem@davemloft.net>
References: <20090408232031.8781.83459.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42494
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753726AbZDKIo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 04:44:28 -0400
In-Reply-To: <20090408232031.8781.83459.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 08 Apr 2009 16:20:31 -0700

> The LED blink code is common for 82599 as well.  It should be moved to
> ixgbe_common.c so both devices can use it, and not have it duplicated.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
