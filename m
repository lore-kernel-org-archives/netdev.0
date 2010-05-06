From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: emaclite: Use resource_size
Date: Thu, 06 May 2010 01:23:06 -0700 (PDT)
Message-ID: <20100506.012306.184837812.davem@davemloft.net>
References: <1273133540-6894-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.linn@xilinx.com,
	kernel-janitors@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34251
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754855Ab0EFIXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 04:23:01 -0400
In-Reply-To: <1273133540-6894-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu,  6 May 2010 10:12:20 +0200

> Use the resource_size function instead of manually calculating the
> resource size.  This reduces the chance of introducing off-by-one
> errors.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied, thanks.
