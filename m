From: Philip Molter <philip@datafoundry.com>
Subject: Re: tg3: tg3_stop_block timed out
Date: Tue, 12 Sep 2006 12:22:33 -0500
Message-ID: <4506ECD9.4050607@datafoundry.com>
References: <1551EAE59135BE47B544934E30FC4FC093FAF4@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailstar.maildev1.aus.datafoundry.com ([209.99.125.22]:5528
	"EHLO mailstar.maildev1.aus.datafoundry.com") by vger.kernel.org
	with ESMTP id S965244AbWILRWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 13:22:31 -0400
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC093FAF4@NT-IRVA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Please try the latest driver.  If you still get the timeouts, I'll
> need to send you some debug patches to dump the state when these
> timeouts occur.

So far, with the new driver, I haven't seen any of these timeouts. 
Normally, we'd have seen them by now.  If they recur at some point in 
the future, I'll post a new message.

Thanks for your help, Michael.
Philip

