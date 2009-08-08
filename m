From: Bill Fink <billfink@mindspring.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Fri, 7 Aug 2009 20:54:42 -0400
Message-ID: <20090807205442.32918186.billfink@mindspring.com>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>
	<20090807221211.GA16874@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>, brice@myri.com,
	gallatin@myri.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:38797 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752366AbZHHAym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 20:54:42 -0400
In-Reply-To: <20090807221211.GA16874@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 7 Aug 2009, Neil Horman wrote:

> You're timing is impeccable!  I just posted a patch for an ftrace module to help
> detect just these kind of conditions:
> http://marc.info/?l=linux-netdev&m=124967650218846&w=2
> 
> Hope that helps you out
> Neil

Thanks!  It could be helpful.  Do you have a pointer to documentation
on how to use it?  And does it require the latest GIT kernel or could
it possibly be used with a 2.6.29.6 kernel?

						-Bill
