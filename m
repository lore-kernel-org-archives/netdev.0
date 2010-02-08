From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [Bugme-new] [Bug 15239] New: Problem with network performance after a while.
Date: Tue, 9 Feb 2010 00:04:38 +0100
Message-ID: <201002090004.38332.rjw@sisk.pl>
References: <bug-15239-10286@http.bugzilla.kernel.org/> <201002082351.30629.rjw@sisk.pl> <20100208.145857.27251976.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	maciej.rutecki@gmail.com,
	Kernel Bugzilla <bugzilla-daemon@bugzilla.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:60551 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751715Ab0BHXYn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2010 18:24:43 -0500
In-Reply-To: <20100208.145857.27251976.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 08 February 2010, David Miller wrote:
> From: "Rafael J. Wysocki" <rjw@sisk.pl>
> Date: Mon, 8 Feb 2010 23:51:30 +0100
> 
> > On Monday 08 February 2010, Andrew Morton wrote:
> >> On Sat, 6 Feb 2010 14:39:46 GMT
> >> bugzilla-daemon@bugzilla.kernel.org wrote:
> >> 
> >> > http://bugzilla.kernel.org/show_bug.cgi?id=15239
> >> 
> >> post-2.6.32 regression, backported into -stable :(
> > 
> > Added, CCing netdev.
> 
> No need, we already worked on this and have a fix,
> see:
> 
> http://marc.info/?l=linux-netdev&m=126565759512718&w=2

Great, thanks!
