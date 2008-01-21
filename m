From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 0/7] bonding: 7 fixes for 2.6.24
Date: Sun, 20 Jan 2008 20:57:46 -0500
Message-ID: <4793FC1A.4090401@pobox.com>
References: <12006159033257-git-send-email-fubar@us.ibm.com> <20080120.171538.12566715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org, andy@greyhouse.net,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42166 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756236AbYAUB5z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jan 2008 20:57:55 -0500
In-Reply-To: <20080120.171538.12566715.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jay Vosburgh <fubar@us.ibm.com>
> Date: Thu, 17 Jan 2008 16:24:56 -0800
> 
>> 	Following are seven patches to fix locking problems,
>> silence locking-related warnings and resolve one recent regression
>> in the current 2.6.24-rc.
> 
> Jeff, are you going to merge this stuff in?
> 
> I'll drop that rtnl_lock() one-liner if so...

Linus has this series in linux-2.6.git, even...

	Jeff



