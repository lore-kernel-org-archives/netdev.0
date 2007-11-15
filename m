From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [Bugme-new] [Bug 9386] New: sis190 network driver crash
Date: Fri, 16 Nov 2007 00:36:52 +0100
Message-ID: <20071115233652.GA22417@electric-eye.fr.zoreil.com>
References: <bug-9386-10286@http.bugzilla.kernel.org/> <20071115115841.30d43003.akpm@linux-foundation.org> <20071115.150041.156510275.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, chris@linuxepos.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:49516 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932528AbXKOXjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 18:39:13 -0500
Content-Disposition: inline
In-Reply-To: <20071115.150041.156510275.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> :
[...]
> I wonder if somehow sis190_phy_task() is creating some kind
> of deadlock when handling the link down and up events.

I should be able to test it during the week end if nobody beats me

The sis190 stands headless in the kitchen. Given the current situation
here, I do not have the oomph to turn the kitchen into a debug lab when
I am back from work.

-- 
Ueimor
