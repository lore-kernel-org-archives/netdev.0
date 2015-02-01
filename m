From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fcntl.h: Fix a typo
Date: Sun, 01 Feb 2015 12:15:22 -0800 (PST)
Message-ID: <20150201.121522.174066581953685271.davem@davemloft.net>
References: <54CE16F9.7030706@sandisk.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org
To: bart.vanassche@sandisk.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39046 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753892AbbBAUPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2015 15:15:25 -0500
In-Reply-To: <54CE16F9.7030706@sandisk.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bart Van Assche <bart.vanassche@sandisk.com>
Date: Sun, 01 Feb 2015 13:07:21 +0100

> In the source file fs/fcntl.c and also in the fcntl() man page one
> can see that the FD_CLOEXEC flag can be manipulated via F_GETFD
> and F_SETFD. Update the comment in <fcntl.h> accordingly.
> 
> Signed-off-by: Bart Van Assche <bart.vanassche@sandisk.com>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>

Netdev is not an appropriate mailing list for this patch, is it?
