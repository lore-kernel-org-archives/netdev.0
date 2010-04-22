From: David Miller <davem@davemloft.net>
Subject: Re: [net-next,1/2] add iovnl netlink support
Date: Thu, 22 Apr 2010 00:09:37 -0700 (PDT)
Message-ID: <20100422.000937.219611809.davem@davemloft.net>
References: <C7F4AD4F.2A34D%scofeldm@cisco.com>
	<201004212313.05060.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: scofeldm@cisco.com, chrisw@redhat.com, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49036
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751731Ab0DVHJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 03:09:33 -0400
In-Reply-To: <201004212313.05060.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 21 Apr 2010 23:13:04 +0200

> My preference would probably be make these a subcategory of the
> if_link, and use the existing RTM_NEWLINK/RTM_DELLINK commands.

I was going to suggest this as well.
