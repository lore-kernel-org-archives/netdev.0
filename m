From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] cxgb4: fix initial addition of MAC address
Date: Tue, 18 May 2010 15:16:57 -0700 (PDT)
Message-ID: <20100518.151657.93442149.davem@davemloft.net>
References: <1274213233-26309-1-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35284
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752606Ab0ERWQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 18:16:48 -0400
In-Reply-To: <1274213233-26309-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Tue, 18 May 2010 13:07:11 -0700

> The call to add the MAC address during link initialization wasn't adding the
> address to one of the HW tables.  Fix.
> 
> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>

Applied.
