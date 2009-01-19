From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.30] cxgb3 - ease msi-x settings conditions
Date: Sun, 18 Jan 2009 21:29:52 -0800 (PST)
Message-ID: <20090118.212952.156342736.davem@davemloft.net>
References: <20090118204836.10826.2994.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com, wenxiong@us.ibm.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60706
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751415AbZASF3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 00:29:51 -0500
In-Reply-To: <20090118204836.10826.2994.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Sun, 18 Jan 2009 12:48:36 -0800

> The driver currently drops to line interrupt mode
> if it did not get all the msi-x vectors it requested.
> 
> Allow msi-x settings when a minimal amount of vectors
> is provided.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Looks good, queued up for 2.6.30
