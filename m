From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 3/4][NETNS][RAW]: Eliminate explicit
 init_net references.
Date: Mon, 14 Jan 2008 05:37:11 -0800 (PST)
Message-ID: <20080114.053711.193051182.davem@davemloft.net>
References: <478B5F75.70608@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48272
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751173AbYANNhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 08:37:15 -0500
In-Reply-To: <478B5F75.70608@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 14 Jan 2008 16:11:17 +0300

> Happily, in all the rest places (->bind callbacks only), that require the 
> struct net, we have a socket, so get the net from it.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
