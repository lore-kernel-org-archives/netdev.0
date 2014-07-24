From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] Revert "usb: gadget: u_ether: synchronize with transmit
 when stopping queue"
Date: Wed, 23 Jul 2014 19:06:40 -0700
Message-ID: <20140724020640.GA20696@kroah.com>
References: <1406166546-21738-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	jeff.westfahl@ni.com, tglx@linutronix.de
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:48957 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756120AbaGXCGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 22:06:45 -0400
Received: from compute6.internal (compute6.nyi.mail.srv.osa [10.202.2.46])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 3BFB222BA1
	for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 22:06:41 -0400 (EDT)
Content-Disposition: inline
In-Reply-To: <1406166546-21738-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2014 at 09:49:06AM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> This reverts commit a9232076374334ca2bc2a448dfde96d38a54349a.

Any reason you didn't cc: the people on that patch, nor the people that
get_maintainer.pl says to?

Odds are Felipe will miss this one...

greg k-h
