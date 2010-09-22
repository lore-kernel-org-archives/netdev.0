From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 3/3] caif: Use default send and receive
 buffer size in caif_socket.
Date: Tue, 21 Sep 2010 18:07:41 -0700 (PDT)
Message-ID: <20100921.180741.246535325.davem@davemloft.net>
References: <1285105486-7649-1-git-send-email-sjur.brandeland@stericsson.com>
	<1285105486-7649-2-git-send-email-sjur.brandeland@stericsson.com>
	<1285105486-7649-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54200
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756287Ab0IVBHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 21:07:21 -0400
In-Reply-To: <1285105486-7649-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Tue, 21 Sep 2010 23:44:46 +0200

> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 
> CAIF sockets should use socket's default send and receive buffers sizes.
> 
> Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>

Applied.
