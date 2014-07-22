From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: skbuff: Use ALIGN macro instead of open
 coding it
Date: Tue, 22 Jul 2014 15:23:36 -0700 (PDT)
Message-ID: <20140722.152336.2242852986214770867.davem@davemloft.net>
References: <1406023583-25851-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52389 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932659AbaGVWXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 18:23:38 -0400
In-Reply-To: <1406023583-25851-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 22 Jul 2014 12:06:23 +0200

> Use ALIGN from linux/kernel.h to define SKB_DATA_ALIGN instead of open
> coding it.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied, thanks.
