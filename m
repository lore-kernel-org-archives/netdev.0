From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2][BRIDGE]: Consolidate error paths in
 br_add_bridge().
Date: Sun, 04 May 2008 17:58:16 -0700 (PDT)
Message-ID: <20080504.175816.31670485.davem@davemloft.net>
References: <481D5C71.9000005@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37189
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752095AbYEEA6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 20:58:16 -0400
In-Reply-To: <481D5C71.9000005@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Sun, 04 May 2008 10:49:21 +0400

> This actually had to be merged with the patch #1, but I decided
> not to mix two changes in one patch.
> 
> There are already two calls to free_netdev() in there, so merge
> them into one.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Looks good, applied.
