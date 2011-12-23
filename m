From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] iproute2: split up ip man page?
Date: Thu, 22 Dec 2011 16:29:59 -0800
Message-ID: <20111222162959.167b9df0@nehalam.linuxnetplumber.net>
References: <20111207131514.6815f813@nehalam.linuxnetplumber.net>
	<20111222103723.59a035df@nehalam.linuxnetplumber.net>
	<20111223001003.GD4767@hell>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:32870 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752765Ab1LWAaC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Dec 2011 19:30:02 -0500
In-Reply-To: <20111223001003.GD4767@hell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 Dec 2011 01:10:03 +0100
Hagen Paul Pfeifer <hagen@jauu.net> wrote:

> * Stephen Hemminger | 2011-12-22 10:37:23 [-0800]:
> 
> >Ok, the ip man page is now broken up. I tried to fix some of the
> >incorrect grammar and usage as well. The pages still need editing for
> >readability.
> 
> Great! Commit 1b1177ed5f3 synched kernel headers. Should I rebase my iproute
> netem rate patch (and again update include/linux/pkt_sched.h for net-next) or
> keep you aware of this?
> 
> Hagen

I am fixing netem loss stuff now. Fixing broken gimodel.
After 3.2 is released, the will merge in support for 3.3 features.
