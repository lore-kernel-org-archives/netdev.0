From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.29] tcp_vegas ssthresh bugfix
Date: Mon, 25 May 2009 22:45:06 -0700 (PDT)
Message-ID: <20090525.224506.211074844.davem@davemloft.net>
References: <20090526013924.GA11266@scriptng>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: doug.leith@nuim.ie
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51849
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751926AbZEZFpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 01:45:06 -0400
In-Reply-To: <20090526013924.GA11266@scriptng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Douglas Leith <doug.leith@nuim.ie>
Date: Tue, 26 May 2009 02:39:24 +0100

> 
> This patch fixes ssthresh accounting issues in tcp_vegas when cwnd decreases
> 
> Signed-off-by: Doug Leith <doug.leith@nuim.ie>

Applied, thanks.
