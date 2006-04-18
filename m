From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC: 2.6 patch] net/netlink/: possible cleanups
Date: Tue, 18 Apr 2006 19:48:41 +0100
Message-ID: <1145386121.21723.28.camel@localhost.localdomain>
References: <20060413162710.GE4162@stusta.de>
	 <20060413.132603.94193712.davem@davemloft.net>
	 <20060414103202.GF4162@stusta.de> <20060414105610.GA18149@2ka.mipt.ru>
	 <20060418141946.GC11582@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:34023 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP id S932158AbWDRSlC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 14:41:02 -0400
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060418141946.GC11582@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Maw, 2006-04-18 at 16:19 +0200, Adrian Bunk wrote:
> OTOH, we also have to always check whether users are expected soon (and 
> recheck whether there are really users after some time) since every 
> single export makes the kernel larger for nearly everyone.

Of course fixing the amount of memory used by an EXPORT_SYMBOL would be
far more productive.

