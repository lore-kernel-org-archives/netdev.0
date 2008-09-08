From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netns bridge: allow bridges in netns!
Date: Mon, 08 Sep 2008 16:20:28 -0700 (PDT)
Message-ID: <20080908.162028.16064976.davem@davemloft.net>
References: <20080906064304.GA7810@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	containers@osdl.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58756
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753158AbYIHXUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 19:20:34 -0400
In-Reply-To: <20080906064304.GA7810@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sat, 6 Sep 2008 10:43:05 +0400

> Bridge as netdevice doesn't cross netns boundaries.
> 
> Bridge ports and bridge itself live in same netns.
> 
> Notifiers are fixed.
> 
> netns propagated from userspace socket for setup and teardown.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied to net-next-2.6
