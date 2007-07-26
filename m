From: David Miller <davem@davemloft.net>
Subject: Re: [RFT] fib_trie: cleanup
Date: Thu, 26 Jul 2007 01:49:02 -0700 (PDT)
Message-ID: <20070726.014902.89039353.davem@davemloft.net>
References: <20070725040304.111550f4.akpm@linux-foundation.org>
	<20070725181557.GF3572@stusta.de>
	<20070726094648.3b7301ae@oldman>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, Robert.Olsson@data.slu.se,
	akpm@linux-foundation.org, paulmck@linux.vnet.ibm.com,
	mingo@elte.hu, josh@kernel.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59135
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757287AbXGZItE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 04:49:04 -0400
In-Reply-To: <20070726094648.3b7301ae@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 26 Jul 2007 09:46:48 +0100

> Try this out:
>      * replace macro's with inlines
>      * get rid of places doing multiple evaluations of NODE_PARENT

No objections from me.

Robert?
