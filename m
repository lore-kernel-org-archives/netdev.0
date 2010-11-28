From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb3: Removing unused return variable
Date: Sun, 28 Nov 2010 11:50:33 -0800 (PST)
Message-ID: <20101128.115033.68119090.davem@davemloft.net>
References: <1290707635-31979-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56332
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751927Ab0K1TuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 14:50:06 -0500
In-Reply-To: <1290707635-31979-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: leitao@linux.vnet.ibm.com
Date: Thu, 25 Nov 2010 15:53:55 -0200

> Currently the ret variable is not used for anything other than
> receive the value of the t3_adapter_error(), which will always be 0,
> because the reset parameter is 0.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Applied to net-next-2.6, thanks.
