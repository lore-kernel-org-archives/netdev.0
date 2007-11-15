From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-velocity: don't oops on MTU change.
Date: Wed, 14 Nov 2007 19:48:05 -0800 (PST)
Message-ID: <20071114.194805.197525006.davem@davemloft.net>
References: <bug-9382-10286@http.bugzilla.kernel.org/>
	<20071114192319.e9423144.akpm@linux-foundation.org>
	<20071114193844.0cab5c7d@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	jnelson-kernel-bugzilla@jamponi.net
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35262
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754968AbXKODsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 22:48:12 -0500
In-Reply-To: <20071114193844.0cab5c7d@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 14 Nov 2007 19:38:44 -0800

> Simple mtu change when device is down.
> Fix http://bugzilla.kernel.org/show_bug.cgi?id=9382.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied.

Thanks for looking at this bug so quickly Stephen.
