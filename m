From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Request for help with iproute2 bugs.
Date: Sat, 26 Dec 2009 10:12:28 -0800
Message-ID: <20091226101228.0d617c48@nehalam>
References: <20091123103742.GA14713@amd64.fatal.se>
	<20091203010824.GA19810@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andreas Henriksson <andreas@fatal.se>, netdev@vger.kernel.org,
	532152@bugs.debian.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55999 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751549AbZLZSMo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Dec 2009 13:12:44 -0500
In-Reply-To: <20091203010824.GA19810@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 3 Dec 2009 12:08:27 +1100
Simon Horman <horms@verge.net.au> wrote:

> On Mon, Nov 23, 2009 at 11:37:42AM +0100, Andreas Henriksson wrote:
> > Hello everybody!
> > 
> > This is a desperate attempt at finding people with time and motivation
> > to look into bugs that has been reported against the iproute package
> > in the debian bug tracking system. The reported bugs are usually
> > not Debian-specific...
> > 
> > You'll find the complete list at http://bugs.debian.org/iproute
> > If you have comments, please email them to <bugnumber>@bugs.debian.org
> > 
> > 
> > Here's a list of interesting candidates, hopefully you'll find some useful
> > comments if you follow the link (usually last comment at the bottom):
> > 
> > http://bugs.debian.org/532152 - incorrectly enumerates existing addresses.
> >   iproute: 'ip addr flush' exits with error on first try
> 
> I've taken a stab at this one.
> 

applied thanks

-- 
