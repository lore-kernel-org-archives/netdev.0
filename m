From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Convert TCP/DCCP listening hash tables to use RCU
Date: Sun, 23 Nov 2008 17:23:26 -0800 (PST)
Message-ID: <20081123.172326.246221214.davem@davemloft.net>
References: <4909D551.9080309@cosmosbay.com>
	<491C2873.60004@cosmosbay.com>
	<49292368.2060201@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, minyard@acm.org, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	cl@linux-foundation.org, a.p.zijlstra@chello.nl, zbr@ioremap.net,
	christian@myri.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57372
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751107AbYKXBX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2008 20:23:28 -0500
In-Reply-To: <49292368.2060201@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sun, 23 Nov 2008 10:33:28 +0100

> [PATCH] net: Convert TCP/DCCP listening hash tables to use RCU

Applied, thanks Eric.
