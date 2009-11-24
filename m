From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: Fix device name compares
Date: Tue, 24 Nov 2009 12:21:35 -0800 (PST)
Message-ID: <20091124.122135.43806243.davem@davemloft.net>
References: <4B0A75A5.8000106@gmail.com>
	<19210.40927.13011.176740@gargle.gargle.HOWL>
	<4B0AA8C9.8060206@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert@herjulf.net, netdev@vger.kernel.org, robert.olsson@its.uu.se
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34670
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932541AbZKXUVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 15:21:17 -0500
In-Reply-To: <4B0AA8C9.8060206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 23 Nov 2009 16:22:49 +0100

> Here is an updated version because the netdev unregister event also needed some changes.
 ...
> [PATCH] pktgen: Fix device name compares

Eric, I put the original version of your patch into net-next-2.6 and
pushed it out already the other day.  Can you give me something relative
with these updates in it?

Thanks.
