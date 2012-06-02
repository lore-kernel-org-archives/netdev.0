From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH ethtool 0/7] Generic netdev features support
Date: Fri, 1 Jun 2012 17:45:17 -0700
Message-ID: <20120601174517.100bf98f@nehalam.linuxnetplumber.net>
References: <1338597227.2770.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Mahesh Bandewar <maheshb@google.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60637 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760267Ab2FBApU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jun 2012 20:45:20 -0400
In-Reply-To: <1338597227.2770.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2 Jun 2012 01:33:47 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> This series adds support for the not-so-new generic netdev features
> ethtool API, along with some test infrastructure and test cases to check
> that it works with old and new kernel versions.  I'm still not convinced
> that there are enough test cases, but I've held this back for too damn
> long already.
> 
> I'd like to include these changes in an ethtool 3.4 release by the end
> of next week, so let me know if there's anything wrong with them.
> 
> Ben.

Slightly off-topic, is anyone working on doing ethtool setting over netlink?
