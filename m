From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6][NETNS]: Introduce a netns_core structure.
Date: Mon, 31 Mar 2008 20:19:03 -0700 (PDT)
Message-ID: <20080331.201903.80090553.davem@davemloft.net>
References: <47F0D464.1090308@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58975
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753109AbYDADTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 23:19:03 -0400
In-Reply-To: <47F0D464.1090308@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 31 Mar 2008 16:09:08 +0400

> There's already some stuff on the struct net, that should better
> be folded into netns_core structure. I'm making the per-proto inuse 
> counter be per-net also, which is also a candidate for this, so 
> introduce this structure and populate it a bit.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
