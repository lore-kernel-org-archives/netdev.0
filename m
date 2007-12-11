From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Use BUILD_BUG_ON in inet_timewait_sock.c checks
Date: Tue, 11 Dec 2007 02:12:46 -0800 (PST)
Message-ID: <20071211.021246.113009866.davem@davemloft.net>
References: <475986E2.6050409@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33128
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751265AbXLKKMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 05:12:46 -0500
In-Reply-To: <475986E2.6050409@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 07 Dec 2007 20:46:10 +0300

> Make the INET_TWDR_TWKILL_SLOTS vs sizeof(twdr->thread_slots)
> check nicer.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Also applied to net-2.6.25, thanks!
