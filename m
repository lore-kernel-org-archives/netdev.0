From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: kernel doc / docbook pdfdocs question
Date: Wed, 30 Sep 2009 17:30:02 -0700
Message-ID: <20090930173002.36da7ffd@s6510>
References: <8223.1254340776@jerryjeff.riw.enoyolf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	netdev <netdev@vger.kernel.org>
To: Doug Maxey <dwm@enoyolf.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40416 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754898AbZJAAaB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2009 20:30:01 -0400
In-Reply-To: <8223.1254340776@jerryjeff.riw.enoyolf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Sep 2009 14:59:36 -0500
Doug Maxey <dwm@enoyolf.org> wrote:

> 
> Randy,
> 
> This may be slightly off topic for this list, but it does involve an
> (as yet un-released) network driver. :)
> 
> Do you have any insight that could guide me toward a fix for an issue
> seen with some header file constructs when trying to generate a pdf
> docbook?
> 

Why clutter docbook output (which is supposed to be about general kernel
API's) with output for data structures in one driver.
