From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: setsockopt()
Date: Thu, 10 Jul 2008 05:06:50 +0400
Message-ID: <20080710010649.GA28491@2ka.mipt.ru>
References: <20080708020235.388a7bd5.billfink@mindspring.com> <adar6a4x510.fsf@cisco.com> <20080708134845.2372a483@speedy> <20080708180500.e8a61231.billfink@mindspring.com> <20080709052534.GA8157@2ka.mipt.ru> <20080709014758.d59be0d8.billfink@mindspring.com> <20080709060341.GA29743@2ka.mipt.ru> <20080709181122.GB488@fieldses.org> <20080709184329.GC5383@2ka.mipt.ru> <20080709222802.GK488@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Fink <billfink@mindspring.com>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Roland Dreier <rdreier@cisco.com>,
	David Miller <davem@davemloft.net>, aglo@citi.umich.edu,
	shemminger@vyatta.com, netdev@vger.kernel.org, rees@umich.edu
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:46881 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753134AbYGJBHm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2008 21:07:42 -0400
Content-Disposition: inline
In-Reply-To: <20080709222802.GK488@fieldses.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 09, 2008 at 06:28:02PM -0400, J. Bruce Fields (bfields@fieldses.org) wrote:
> OK, thanks.  Would the following be any more clearer and/or accurate?

Looks good, thank you :)
It is likely the first ever mention of the fact, that SO_RECV/SNDBUF
disables autotuning.

-- 
	Evgeniy Polyakov
