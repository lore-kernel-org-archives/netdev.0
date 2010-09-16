From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/18] misdn: kill big kernel lock
Date: Wed, 15 Sep 2010 19:31:37 -0700 (PDT)
Message-ID: <20100915.193137.55845010.davem@davemloft.net>
References: <1284492909-7147-1-git-send-email-arnd@arndb.de>
	<1284492909-7147-15-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58349
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753217Ab0IPCbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 22:31:18 -0400
In-Reply-To: <1284492909-7147-15-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 14 Sep 2010 21:35:05 +0200

> The use of the big kernel lock in misdn is completely
> bogus, so let's just remove it.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
