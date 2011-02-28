From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: fix sparse warning
Date: Mon, 28 Feb 2011 12:40:26 -0800 (PST)
Message-ID: <20110228.124026.232742958.davem@davemloft.net>
References: <20110223094033.0c2268b4@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56397
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752712Ab1B1Ujt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 15:39:49 -0500
In-Reply-To: <20110223094033.0c2268b4@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 23 Feb 2011 09:40:33 -0800

> Fix use of zero where NULL expected. And wrap long line.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
