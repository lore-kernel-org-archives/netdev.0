From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 0/2][RFC] Network Event Notifier Mechanism
Date: Thu, 22 Jun 2006 08:53:00 -0500
Message-ID: <1150984380.27156.4.camel@stevo-desktop>
References: <20060621184519.10425.69175.stgit@stevo-desktop>
	 <20060622.015728.59653992.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:29474 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1161130AbWFVNxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 09:53:01 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060622.015728.59653992.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-22 at 01:57 -0700, David Miller wrote:
> From: Steve Wise <swise@opengridcomputing.com>
> Date: Wed, 21 Jun 2006 13:45:19 -0500
> 
> > This patch implements a mechanism that allows interested clients to
> > register for notification of certain network events.
> 
> We have a generic network event notification facility called
> netlink, please use it and extend it for your needs if necessary.

I'll investigate this.  

Thanks,


Steve.

