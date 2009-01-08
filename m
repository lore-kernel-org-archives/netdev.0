From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] IPV6 address management
Date: Thu, 8 Jan 2009 14:01:22 -0800
Message-ID: <20090108140122.5488d84c@extreme>
References: <20090108134402.6e88438f@extreme>
	<20090108.135125.13529853.davem@davemloft.net>
	<20090108135614.23aed603@extreme>
	<20090108.135819.103389689.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37511 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751753AbZAHWBX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 17:01:23 -0500
In-Reply-To: <20090108.135819.103389689.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 08 Jan 2009 13:58:19 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 8 Jan 2009 13:56:14 -0800
> 
> > On Thu, 08 Jan 2009 13:51:25 -0800 (PST)
> > David Miller <davem@davemloft.net> wrote:
> > 
> > > From: Stephen Hemminger <shemminger@vyatta.com>
> > > Date: Thu, 8 Jan 2009 13:44:02 -0800
> > > 
> > > > On Thu, 08 Jan 2009 12:58:30 -0800 (PST)
> > > > David Miller <davem@davemloft.net> wrote:
> > > > 
> > > > > Or is it to gradually get people to use the non-default
> > > > > (via distribution sysctl settings etc.) and eventually
> > > > > make it the default?
> > > > No plan to ever change the default. Just ship with sysctl.conf
> > > > setting.
> > > 
> > > If the distributions all ship with the sysctl changed
> > > to the non-default, our "default" is pretty meaningless
> > > wouldn't you say?
> > 
> > It seems the only logical way to undo a poor choice
> > in the original design
> 
> If the dists can do it so unilaterally, why can't we?
> 
> Everything about these proposals is a contradiction.
> That's why I don't like them at all.
> 
> I say we keep the behavior, we don't change or break
> anything, and people need to learn how to cope with it.

Fine, it won't be the first or last vendor specific kernel patch.
