From: David Howells <dhowells@redhat.com>
Subject: Re: Possible bug in netlink_recvmsg()
Date: Thu, 19 Apr 2007 17:07:34 +0100
Message-ID: <8969.1176998854@redhat.com>
References: <20070413.141117.101862281.davem@davemloft.net>  <1864.1176487711@redhat.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57911 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1766835AbXDSQHo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2007 12:07:44 -0400
In-Reply-To: <20070413.141117.101862281.davem@davemloft.net> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

> See this fix in my net-2.6.22 tree:
> 
> commit ad495d7b6cfcd1bc2eaf06c42699be0bb5d84234
> Author: David S. Miller <davem@sunset.davemloft.net>
> Date:   Tue Mar 6 17:02:35 2007 -0800

Ummm... That seems to conflict with something in your net-2.6 tree.  Which one
should I use?

David
