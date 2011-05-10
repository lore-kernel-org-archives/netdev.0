From: David Miller <davem@davemloft.net>
Subject: Re: slcan: fix ldisc->open retval
Date: Tue, 10 May 2011 13:12:36 -0700 (PDT)
Message-ID: <20110510.131236.246540445.davem@davemloft.net>
References: <4DC8D681.8000602@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matvejchikov@gmail.com
To: socketcan@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43057
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751450Ab1EJUNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:13:09 -0400
In-Reply-To: <4DC8D681.8000602@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Tue, 10 May 2011 08:09:05 +0200

> TTY layer expects 0 if the ldisc->open operation succeeded.
> 
> Reported-by: Matvejchikov Ilya <matvejchikov@gmail.com>
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

Applied, thanks.
