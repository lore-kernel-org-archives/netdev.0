From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 4/4][NETNS][RAW]: Create the
 /proc/net/raw(6) in each namespace.
Date: Mon, 14 Jan 2008 05:37:17 -0800 (PST)
Message-ID: <20080114.053717.29122628.davem@davemloft.net>
References: <478B5FE4.3020602@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48275
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751247AbYANNhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 08:37:19 -0500
In-Reply-To: <478B5FE4.3020602@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 14 Jan 2008 16:13:08 +0300

> To do so, just register the proper subsystem and create files in
> ->init callbacks.
> 
> No other special per-namespace handling for raw sockets is required.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
