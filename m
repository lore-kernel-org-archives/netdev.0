From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pxa168_eth: mdiobus_scan() doesn't return NULL anymore
Date: Mon, 09 May 2016 00:14:34 -0400 (EDT)
Message-ID: <20160509.001434.1561770698500730391.davem@davemloft.net>
References: <19240252.825Vlx6L0H@wasted.cogentembedded.com>
	<3730936.r1jNy7SQee@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54053 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbcEIEOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 00:14:37 -0400
In-Reply-To: <3730936.r1jNy7SQee@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sat, 07 May 2016 22:53:40 +0300

> Now that mdiobus_scan() doesn't return NULL on failure anymore, this driver
> no  longer needs to check for it...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
