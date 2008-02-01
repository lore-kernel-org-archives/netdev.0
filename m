From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] [PKTGEN] Remove an unused definition in
 pktgen.c.
Date: Thu, 31 Jan 2008 16:43:05 -0800 (PST)
Message-ID: <20080131.164305.98153539.davem@davemloft.net>
References: <eb3ff54b0801230638j4e0ece76sf0a2592477050fee@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34902
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752201AbYBAAmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 19:42:43 -0500
In-Reply-To: <eb3ff54b0801230638j4e0ece76sf0a2592477050fee@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Wed, 23 Jan 2008 16:38:09 +0200

> Hi,
> - Remove an unused definition (LAT_BUCKETS_MAX) in net/core/pktgen.c.
> - Remove the corresponding comment.
> - The LAT_BUCKETS_MAX seems to have to do with a patch from a long
> time ago which was not applied (Ben Greear), which dealt with latency
> counters.
> 
> See, for example : http://oss.sgi.com/archives/netdev/2002-09/msg00184.html
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied, thanks.
