From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6][NETNS]: Tcp-v6 sockets per-net lookup.
Date: Thu, 31 Jan 2008 05:07:32 -0800 (PST)
Message-ID: <20080131.050732.228039266.davem@davemloft.net>
References: <47A1C1B0.3020807@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40382
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933641AbYAaNHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 08:07:11 -0500
In-Reply-To: <47A1C1B0.3020807@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 31 Jan 2008 15:40:16 +0300

> Add a net argument to inet6_lookup and propagate it further. 
> Actually, this is tcp-v6 implementation of what was done for 
> tcp-v4 sockets in a previous patch.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
