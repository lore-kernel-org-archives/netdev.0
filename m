From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: partial support and phy init for the 8168d
Date: Sun, 01 Nov 2009 22:46:45 -0800 (PST)
Message-ID: <20091101.224645.262714217.davem@davemloft.net>
References: <20091007224420.GA20170@electric-eye.fr.zoreil.com>
	<1257092683.3136.325.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	edward_hsu@realtek.com.tw
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50439
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752827AbZKBGqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 01:46:21 -0500
In-Reply-To: <1257092683.3136.325.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 01 Nov 2009 16:24:43 +0000

> I believe this is patching machine code in the PHY.  And we do not have
> source for that code, so it cannot possibly be distributed under GPL.

You don't know if it's machine code or some data values that
are used to control the PHY's execution.

In fact I would really be surprised if they had some cpu interpeting
code in the 8168d PHY.

You did do some research about that before making such accusations
right? :-)

