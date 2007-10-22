From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/6] Convert bonding timers to workqueues
Date: Mon, 22 Oct 2007 14:34:48 -0400
Message-ID: <471CED48.207@garzik.org>
References: <11920760494096-git-send-email-fubar@us.ibm.com>	 <11920760502756-git-send-email-fubar@us.ibm.com>	 <4713B44E.7030902@pobox.com> <20038.1192475339@death> <170fa0d20710220755w744e8ec8w1d85cae4f4be822e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: Mike Snitzer <snitzer@gmail.com>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38117 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752023AbXJVSez (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 14:34:55 -0400
In-Reply-To: <170fa0d20710220755w744e8ec8w1d85cae4f4be822e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mike Snitzer wrote:
> Given that Jay rebased and posted updated bonding locking patches on
> Oct 17 will you be pushing them for inclusion in 2.6.24-rc1?  or
> 2.6.24-rcX?  I don't see them queued in your netdev-2.6 tree.  These
> bonding locking issues have been a problem for some time and it would
> be very good to get them fixed upstream sooner rather than later.


I wasn't aware this brand-new code is a bug fix?

Normally brand new code needs to be posted and reviewed and committed to 
a tree -before- the merge window opens.

	Jeff


