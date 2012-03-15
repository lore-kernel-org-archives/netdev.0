From: Dave Jones <davej@redhat.com>
Subject: Re: 3.3-rc snmp6 panic
Date: Thu, 15 Mar 2012 10:42:27 -0400
Message-ID: <20120315144226.GA5409@redhat.com>
References: <20120315052506.GA5974@redhat.com>
 <1331794575.2543.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29340 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756213Ab2COOm3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 10:42:29 -0400
Content-Disposition: inline
In-Reply-To: <1331794575.2543.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 14, 2012 at 11:56:15PM -0700, Eric Dumazet wrote:
 
 > > This machine is running an snmpd, for my mrtg setup, so the teardown of that
 > > service is probably what's triggering it. But I can start/stop it in a loop
 > > as much as I want without it happening, so maybe the kernel needs to accumulate
 > > some state from it for a while first ?
 > > 
 > > Anyone have any ideas what's happening here ?
 > 
 > Hmm, please try :

Will do. Given I can't reproduce it quickly though, it might be a while
before I can provide feedback on whether it does the trick :)

thanks,

	Dave
