From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 3/10][NETNS][FRAGS]: Make the nqueues
 counter per-namespace.
Date: Tue, 22 Jan 2008 06:06:35 -0800 (PST)
Message-ID: <20080122.060635.151697647.davem@davemloft.net>
References: <4795F524.8060204@openvz.org>
	<4795F675.5020909@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49782
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754986AbYAVOG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 09:06:28 -0500
In-Reply-To: <4795F675.5020909@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 22 Jan 2008 16:58:13 +0300

> This is simple - just move the variable from struct inet_frags
> to struct netns_frags and adjust the usage appropriately.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
