From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: whitespace fixes
Date: Fri, 02 Mar 2007 16:50:53 -0800 (PST)
Message-ID: <20070302.165053.41877637.davem@davemloft.net>
References: <20070302140449.1e86aef4@freekitty>
	<20070302.155527.85408614.davem@davemloft.net>
	<20070302164719.6dfc78c1@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37344
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992815AbXCCAuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 19:50:55 -0500
In-Reply-To: <20070302164719.6dfc78c1@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 2 Mar 2007 16:47:19 -0800

> Resend with less garbage...
> 
> The udp code is full of bad indenting, extra whitespace and other
> style confusion.  It makes no sense to declare functions that are used
> outside the current file (extern) as inline.
> 
> Signed-off-by: Stephen Hemminger <shemminge@linux-foundation.org>

Looks good, I'll try to apply this when I cut the net-2.6.22
tree.

Thanks.
