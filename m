From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netdev: stop Features changed message
Date: Fri, 20 May 2011 11:31:39 -0700
Message-ID: <20110520113139.6292eee2@nehalam>
References: <20110520090208.7709bec3@nehalam>
	<20110520.142650.1065397635610543796.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34875 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934869Ab1ETSbo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 May 2011 14:31:44 -0400
In-Reply-To: <20110520.142650.1065397635610543796.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 May 2011 14:26:50 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Fri, 20 May 2011 09:02:08 -0700
> 
> > The new in 2.6.39 message "Features changed:" occurs a lot
> > on many configurations. It provides information to driver developers
> > but is not user friendly. Printing out hex values is just confusing.
> > Reduce priority so that it doesn't show up unless debugging.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> THis was already in net-2.6 and is queued up for 2.6.39-stable

ok.

-- 
