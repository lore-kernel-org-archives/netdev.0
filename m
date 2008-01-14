From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 2/4][NETNS][RAW]: Make /proc/net/raw(6) show
 per-namespace socket list.
Date: Mon, 14 Jan 2008 05:37:04 -0800 (PST)
Message-ID: <20080114.053704.232083055.davem@davemloft.net>
References: <478B5EDA.4000407@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48269
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751081AbYANNhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 08:37:07 -0500
In-Reply-To: <478B5EDA.4000407@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 14 Jan 2008 16:08:42 +0300

> Pull the struct net pointer up to the showing functions
> to filter the sockets depending on their namespaces.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
