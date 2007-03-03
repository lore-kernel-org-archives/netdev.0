From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] pktgen: fix device name handling
Date: Fri, 02 Mar 2007 16:02:36 -0800 (PST)
Message-ID: <20070302.160236.85417749.davem@davemloft.net>
References: <20070227120447.55a7e39d@freekitty>
	<20070227121312.66b268df@freekitty>
	<17893.46781.170641.654215@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46286
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992778AbXCCACi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 19:02:38 -0500
In-Reply-To: <17893.46781.170641.654215@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Olsson <Robert.Olsson@data.slu.se>
Date: Wed, 28 Feb 2007 18:07:09 +0100

> Yes it seems be handle dev name change. So configuration scripts should
> use ifindex now :)
> 
> Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

I will apply all 4 of these patches to net-2.6.22, thanks everyone.
