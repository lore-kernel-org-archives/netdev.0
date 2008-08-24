From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix tcp header size miscalculation when window
 scale is unused
Date: Sat, 23 Aug 2008 21:40:13 -0700 (PDT)
Message-ID: <20080823.214013.29359753.davem@davemloft.net>
References: <C2868EA2-EAC8-48F4-8CA5-01B7437FD72D@emc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: love_phil@emc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48467
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751440AbYHXEkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2008 00:40:18 -0400
In-Reply-To: <C2868EA2-EAC8-48F4-8CA5-01B7437FD72D@emc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philip Love <love_phil@emc.com>
Date: Sat, 23 Aug 2008 10:18:27 -0700

> tcp: fix tcp header size miscalculation when window scale is unused
> 
> The size of the TCP header is miscalculated when the window scale ends  
> up being
> 0. Additionally, this can be induced by sending a SYN to a passive  
> open port
> with a window scale option with value 0.
> 
> Signed-off-by: Philip Love <love_phil@emc.com>

This patch has been mangled by your email client, long lines have been
broken up, leading spaces and tabs have been converted to pure tab
characters, etc.

There I cannot apply the patch.

Please turn off all content modifications in your email client and
resubmit this, thank you.
