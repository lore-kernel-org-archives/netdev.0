From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6][NETNS]: Udp sockets per-net lookup.
Date: Thu, 31 Jan 2008 05:08:13 -0800 (PST)
Message-ID: <20080131.050813.244570068.davem@davemloft.net>
References: <47A1C216.9000303@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40387
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933903AbYAaNHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 08:07:53 -0500
In-Reply-To: <47A1C216.9000303@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 31 Jan 2008 15:41:58 +0300

> Add the net parameter to udp_get_port family of calls and 
> udp_lookup one and use it to filter sockets.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
