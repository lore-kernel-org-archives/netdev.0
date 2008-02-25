From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: fix integer as NULL pointer sparse warnings in
 tipc
Date: Sun, 24 Feb 2008 18:39:13 -0800 (PST)
Message-ID: <20080224.183913.55102968.davem@davemloft.net>
References: <1203904745.1767.19.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, akpm@linux-foundation.org, netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35503
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751986AbYBYCib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2008 21:38:31 -0500
In-Reply-To: <1203904745.1767.19.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Sun, 24 Feb 2008 17:59:05 -0800

> net/tipc/cluster.c:145:2: warning: Using plain integer as NULL pointer
> net/tipc/link.c:3254:36: warning: Using plain integer as NULL pointer
> net/tipc/ref.c:151:15: warning: Using plain integer as NULL pointer
> net/tipc/zone.c:85:2: warning: Using plain integer as NULL pointer
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied, thanks.
