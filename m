From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pktgen: restore nanosec delays
Date: Sun, 04 Oct 2009 21:09:48 -0700 (PDT)
Message-ID: <20091004.210948.258266533.davem@davemloft.net>
References: <4AC737E6.1050809@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45065
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751392AbZJEEJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 00:09:53 -0400
In-Reply-To: <4AC737E6.1050809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 03 Oct 2009 13:39:18 +0200

> Commit fd29cf72 (pktgen: convert to use ktime_t)
> inadvertantly converted "delay" parameter from nanosec to microsec.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
