From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH 0/4] llc enhancements
Date: Fri, 4 Dec 2009 02:20:14 +0200
Message-ID: <200912040220.14402.opurdila@ixiacom.com>
References: <1259879498-27860-1-git-send-email-opurdila@ixiacom.com> <20091203.155553.236357128.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@ghostprotocols.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:26895 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755287AbZLDAXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 19:23:22 -0500
In-Reply-To: <20091203.155553.236357128.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 04 December 2009 01:55:53 you wrote:
> From: Octavian Purdila <opurdila@ixiacom.com>
> Date: Fri,  4 Dec 2009 00:31:34 +0200
> 
> > This patch series introduces a couple of general enhancements to LLC
> > socket code as well as changes to scale the LLC socket lookup code for
> > a large number of interfaces needed for our uses cases (STP traffic
> > generation from a large number of ports, via virtual network
> > interfaces).
> 
> These patches are still in flux, in particular the hash table
> bits need changes, so this stuff will have to wait until the
> next merge window, it's too late for the current one sorry.
> 

Sure, not problem, I didn't intended these for this merge window. I've should 
have marked them as [RFC PATCH], sorry for the confusion.
