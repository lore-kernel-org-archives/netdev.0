From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/3] myri10ge update
Date: Mon, 14 Aug 2006 18:03:45 -0400
Message-ID: <44E0F341.1090907@garzik.org>
References: <44E0F0A1.2000104@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:933 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964999AbWHNWDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 18:03:47 -0400
To: Brice Goglin <brice@myri.com>
In-Reply-To: <44E0F0A1.2000104@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> Hi,
> 
> Here's 3 new minor updates for the myri10ge driver:
> 
> 1) define some previously hardwired firmware constants
> 2) allow to disable link status change reporting
> 3) convert to netdev_alloc_skb

Patches 1 and 3 look OK.  They are cleanups, and will need to go into 
#upstream (2.6.19) rather than #upstream-fixes (2.6.18-rc).

Should I go ahead and attempt to apply 1 and 3, or wait?

	Jeff



