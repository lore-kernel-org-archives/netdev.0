From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 [PATCH 0/3] dccp: ccid-3 fixes and simplifications
Date: Wed, 15 Sep 2010 20:26:52 -0700 (PDT)
Message-ID: <20100915.202652.124065501.davem@davemloft.net>
References: <dccp_ccid3_simplifications>
	<1284552623-16283-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37961
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752355Ab0IPD0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 23:26:33 -0400
In-Reply-To: <1284552623-16283-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 15 Sep 2010 14:10:20 +0200

> please find attached a set of 3 CCID-3 patches from the test tree.
> All have been in the test tree a long time and compile independently.
> 
>  Patch #1: Fixes a bug and simplifies the packet scheduling algorithm.
>  Patch #2: Replaces buggy RTT sampling history lookup.
>  Patch #3: Simplifies the CCID-3 tx-option parsing routine.
> 
> This set is also available based on a fresh (today's) copy of net-next-2.6, 
> 
> 	git://eden-feed.erg.abdn.ac.uk/net-next-2.6  [subtree 'dccp']

Looks good, pulled, thanks a lot Gerrit!
