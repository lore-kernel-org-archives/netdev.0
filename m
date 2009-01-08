From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] IPV6 address management
Date: Thu, 08 Jan 2009 13:51:25 -0800 (PST)
Message-ID: <20090108.135125.13529853.davem@davemloft.net>
References: <20090108121220.789325a6@extreme>
	<20090108.125830.142298950.davem@davemloft.net>
	<20090108134402.6e88438f@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46237
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757240AbZAHVvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 16:51:23 -0500
In-Reply-To: <20090108134402.6e88438f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 8 Jan 2009 13:44:02 -0800

> On Thu, 08 Jan 2009 12:58:30 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > Or is it to gradually get people to use the non-default
> > (via distribution sysctl settings etc.) and eventually
> > make it the default?
> No plan to ever change the default. Just ship with sysctl.conf
> setting.

If the distributions all ship with the sysctl changed
to the non-default, our "default" is pretty meaningless
wouldn't you say?
