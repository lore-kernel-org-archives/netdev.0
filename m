From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sunhme: Use return value of register_netdev
Date: Thu, 19 Aug 2010 00:06:48 -0700 (PDT)
Message-ID: <20100819.000648.173864424.davem@davemloft.net>
References: <1282061585-19527-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52933
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751699Ab0HSHG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 03:06:29 -0400
In-Reply-To: <1282061585-19527-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 17 Aug 2010 18:13:05 +0200

> Use the return value provided by register_netdev on error instead of
> using a previously set value.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
