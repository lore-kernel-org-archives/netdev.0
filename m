From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Cleanup the IPv6 addresses printing in /proc files
Date: Tue, 23 Oct 2007 20:43:50 -0700 (PDT)
Message-ID: <20071023.204350.59654390.davem@davemloft.net>
References: <471E2342.8090907@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59821
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753302AbXJXDoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 23:44:05 -0400
In-Reply-To: <471E2342.8090907@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 23 Oct 2007 20:37:22 +0400

> The /proc/net udp6, tcp6 and raw6 files print the IPs of
> the connection ends. Make a NIP6Lxxx macros (L stands for
> "long") for making the printing code look nicer.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks.
