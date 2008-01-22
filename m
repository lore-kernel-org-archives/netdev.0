From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 4/10][NETNS][FRAGS]: Make the mem counter
 per-namespace.
Date: Tue, 22 Jan 2008 06:07:37 -0800 (PST)
Message-ID: <20080122.060737.239255907.davem@davemloft.net>
References: <4795F524.8060204@openvz.org>
	<4795F6CD.7000908@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49786
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753628AbYAVOHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 09:07:30 -0500
In-Reply-To: <4795F6CD.7000908@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 22 Jan 2008 16:59:41 +0300

> This is also simple, but introduces more changes, since 
> then mem counter is altered in more places.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
