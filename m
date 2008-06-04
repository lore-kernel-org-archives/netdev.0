From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix for race
 =?koi8-r?Q?condition=5Fintroduced=5Fby=5Fthe=5Ftem?=
 =?koi8-r?Q?porary=5Fdrop=5Fof=5Fthe=5Fsocket=5F=9Alock?= in
 skb_splice_bits.
Date: Wed, 04 Jun 2008 15:45:37 -0700 (PDT)
Message-ID: <20080604.154537.192232416.davem@davemloft.net>
References: <200805282253.22688.opurdila@ixiacom.com>
	<20080528200504.GA7349@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: opurdila@ixiacom.com, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52567
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751934AbYFDWpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 18:45:38 -0400
In-Reply-To: <20080528200504.GA7349@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 29 May 2008 00:05:04 +0400

> On Wed, May 28, 2008 at 10:53:22PM +0300, Octavian Purdila (opurdila@ixiacom.com) wrote:
> > This patch applies to 2.6.25 and fixes the crashes in tcp_read_sock and 
> > skb_splice_bits reported on the mailing list earlier. 
> 
> Ack :)

Applied, thanks everyone.
