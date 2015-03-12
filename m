From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 0/3] EEE support for mv88e6172
Date: Thu, 12 Mar 2015 13:14:16 +0100
Message-ID: <20150312121416.GF14112@lunn.ch>
References: <1426025160-13992-1-git-send-email-andrew@lunn.ch>
 <20150311.165931.2141833376642325076.davem@davemloft.net>
 <55015248.9090103@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58491 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932158AbbCLMRm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2015 08:17:42 -0400
Content-Disposition: inline
In-Reply-To: <55015248.9090103@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2015 at 01:46:00AM -0700, Guenter Roeck wrote:
> On 03/11/2015 01:59 PM, David Miller wrote:
> >From: Andrew Lunn <andrew@lunn.ch>
> >Date: Tue, 10 Mar 2015 23:05:56 +0100
> >
> >>This patchset contains two cleanups and then adds EEE support
> >>to the mv88e6172, using the base provided by Guenter Roeck
> >>
> >>Tested on a WRT1900AC with mv88e6172 and DIR665 with mv88e6171.
> >
> >This series does not apply cleanly to net-next.
> >
> >I really want to discourage you posting patches against trees other
> >that net and net-next like this, without CLEARLY marking in the
> >Subject lines that this patch series is special and that I should
> >not try to review and apply it at all.
> >
> 
> Andrew,

Yes, i messed up :-(
 
> I see two options: I can submit my entire series of HW bridging
> patches for mv88e6xxx, or I submit the introductory patches of that
> series (the ones refactoring the code to prepare for HW bridging)
> plus your (rebased) patches on top of it.
> 
> What do you think ?

There is no rush with these patches. When you are ready, post the
whole hardware bridge patches for review. Once they are accepted, i
will try again with the EEE patches for mv88e6171.

     Andrew
