From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6 [BUG-FIX] [PATCH 1/1] dccp: Fix panic in
 retransmission mechanism
Date: Mon, 18 Aug 2008 21:14:57 -0700 (PDT)
Message-ID: <20080818.211457.193683740.davem@davemloft.net>
References: <20080804104632.GC3482@gerrit.erg.abdn.ac.uk>
	<48A9027B.6090109@cn.fujitsu.com>
	<20080818160029.GA30056@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yjwei@cn.fujitsu.com
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55758
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751103AbYHSEO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 00:14:58 -0400
In-Reply-To: <20080818160029.GA30056@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 18 Aug 2008 18:00:29 +0200

> can you please consider this net-2.6 bug fix - this fixes a panic()
> triggered for some packet exchanges.
> 
> ----------------------------> Patch <-----------------------------------
> dccp: Fix panic caused by too early termination of retransmission mechanism

Applied, thanks Gerrit.
