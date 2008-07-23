From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: Fix/rewrite packet filtering logic
Date: Tue, 22 Jul 2008 21:52:44 -0700 (PDT)
Message-ID: <20080722.215244.106348290.davem@davemloft.net>
References: <20080722.171111.267353608.davem@davemloft.net>
	<48867BC3.3070506@garzik.org>
	<4886B76A.6000907@qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, rusty@rustcorp.com.au, netdev@vger.kernel.org,
	sjackman@gmail.com, linuxkernel@bristyle.com,
	virtualization@lists.linux-foundation.org, borntraeger@de.ibm.com
To: maxk@qualcomm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37043
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752422AbYGWEwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 00:52:45 -0400
In-Reply-To: <4886B76A.6000907@qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Max Krasnyansky <maxk@qualcomm.com>
Date: Tue, 22 Jul 2008 21:45:30 -0700

> Jeff Garzik wrote:
> > David Miller wrote:
> >> Jeff, I already added this particular patch to the tree
> >> a week or so ago.
> > 
> > Yeah, later on in my queue were the fixes.
> 
> I'm not sure I'm following. What fixes ? Are you talking about fixing sparse
> warnings or something else ?

He's talking about sparse fixes.
