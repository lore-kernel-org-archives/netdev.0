From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] Lost locking in fl6_sock_lookup
Date: Thu, 18 Oct 2007 05:33:46 -0700 (PDT)
Message-ID: <20071018.053346.122594452.davem@davemloft.net>
References: <47174950.6060409@openvz.org>
	<20071018.051647.23015283.davem@davemloft.net>
	<47175019.4090004@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56559
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756686AbXJRMdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 08:33:33 -0400
In-Reply-To: <47175019.4090004@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 18 Oct 2007 16:22:49 +0400

> Oops. You're right here :( I looked at the ip6_fl_lock
> and messed it with the ip6_sk_fl_lock.
> 
> Should I resend the whole patch, or just make an 
> incremental one?

Please make an incremental one.

And hurry, I'm trying to go to bed :-)))
