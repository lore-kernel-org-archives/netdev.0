From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4/tcp_input.c: fix compilation breakage when
 FASTRETRANS_DEBUG > 1
Date: Mon, 31 May 2010 23:48:26 -0700 (PDT)
Message-ID: <20100531.234826.98870547.davem@davemloft.net>
References: <1275330055.14079.8.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55103
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753942Ab0FAGsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 02:48:17 -0400
In-Reply-To: <1275330055.14079.8.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 31 May 2010 11:20:55 -0700

> Commit: c720c7e8383aff1cb219bddf474ed89d850336e3 missed these.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
