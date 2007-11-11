From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] Cleanup the xfrm4_tunnel_(un)register
Date: Sat, 10 Nov 2007 21:49:08 -0800 (PST)
Message-ID: <20071110.214908.39530836.davem@davemloft.net>
References: <47345DA7.2030107@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48501
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752046AbXKKFtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 00:49:09 -0500
In-Reply-To: <47345DA7.2030107@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 09 Nov 2007 16:16:23 +0300

> Both check for the family to select an appropriate tunnel list.
> Consolidate this check and make the for() loop more readable.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks.
