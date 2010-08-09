From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] net: Provide details on watchdog timeout.
Date: Mon, 09 Aug 2010 13:10:17 -0700 (PDT)
Message-ID: <20100809.131017.112606336.davem@davemloft.net>
References: <1281383954-23765-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38781
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756684Ab0HIUJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 16:09:57 -0400
In-Reply-To: <1281383954-23765-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Mon,  9 Aug 2010 12:59:14 -0700

> This keeps the WARN_ON but will also log normal kernel messages
> after the WARN_ON logic has happened once.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>

I think this warning is fine as-is.
