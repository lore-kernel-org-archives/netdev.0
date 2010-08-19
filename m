From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] greth: Use return value of register_netdev
Date: Thu, 19 Aug 2010 00:05:52 -0700 (PDT)
Message-ID: <20100819.000552.220051390.davem@davemloft.net>
References: <1282061484-19377-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kristoffer@gaisler.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52923
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751018Ab0HSHFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 03:05:33 -0400
In-Reply-To: <1282061484-19377-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 17 Aug 2010 18:11:24 +0200

> Use the return value provided by register_netdev on error instead of
> hard setting it to -ENOMEM.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
