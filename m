From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] r8169 driver fixes
Date: Thu, 03 Feb 2011 16:11:33 -0800 (PST)
Message-ID: <20110203.161133.48502801.davem@davemloft.net>
References: <20110203172557.GA9024@electric-eye.fr.zoreil.com>
	<20110203.151802.39181951.davem@davemloft.net>
	<20110203235500.GA9137@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ivecera@redhat.com, hayeswang@realtek.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42020
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753183Ab1BDAK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 19:10:57 -0500
In-Reply-To: <20110203235500.GA9137@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 4 Feb 2011 00:55:00 +0100

> David Miller <davem@davemloft.net> :
>> These are bug fixes, but this GIT branch is based upon net-next-2.6,
>> what is the intent here?
> 
> It should have been based on $(git merge-base master net-2.6) instead
> of net-ext-2.6.
> 
> I'll rebase it after some sleep.

Ok, thank you.
