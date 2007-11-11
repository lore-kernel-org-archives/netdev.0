From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make helper to get dst entry and "use" is
Date: Sat, 10 Nov 2007 21:28:51 -0800 (PST)
Message-ID: <20071110.212851.178881684.davem@davemloft.net>
References: <4735C060.4070203@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34709
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751080AbXKKF2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 00:28:52 -0500
In-Reply-To: <4735C060.4070203@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Sat, 10 Nov 2007 17:29:52 +0300

> There are many places that get the dst entry, increase the
> __use counter and set the "lastuse" time stamp.
> 
> Make a helper for this.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Nice cleanup, applied.

Thanks!
