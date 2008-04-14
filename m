From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix kernel-doc for skb_segment
Date: Sun, 13 Apr 2008 21:53:00 -0700 (PDT)
Message-ID: <20080413.215300.94136523.davem@davemloft.net>
References: <20080407182844.GP21637@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54077
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751588AbYDNEw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 00:52:58 -0400
In-Reply-To: <20080407182844.GP21637@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 7 Apr 2008 19:28:45 +0100

> The kernel-doc comment for skb_segment is clearly wrong.  This states what
> it actually does.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied to net-2.6, thanks Ben.
