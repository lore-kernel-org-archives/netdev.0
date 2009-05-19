From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.29] tcp_vegas ssthresh bug fix
Date: Tue, 19 May 2009 14:26:43 -0700 (PDT)
Message-ID: <20090519.142643.245648109.davem@davemloft.net>
References: <20090519200519.GA8793@scriptng>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: doug.leith@nuim.ie
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43506
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751897AbZESV0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 17:26:44 -0400
In-Reply-To: <20090519200519.GA8793@scriptng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Douglas Leith <doug.leith@nuim.ie>
Date: Tue, 19 May 2009 21:05:19 +0100

> This patch fixes a minor bug in tcp_vegas.c which affects ssthresh accounting
> when vegas congestion control decreases snd_cwnd.
> 
> Signed-off-by: Doug Leith <doug.leith@nuim.ie>
> 
> ---
> patch inline and as attachment 

Still corrupted, both copies.

All of the context lines of the patch have been removed by
whatever you used to generate that diff.
