From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: New driver questions: Attansic L1 gigabit NIC
Date: Wed, 16 Aug 2006 11:05:01 -0700
Message-ID: <20060816110501.0d7502a8@localhost.localdomain>
References: <44DFBFBE.1070201@bellsouth.net>
	<20060815143457.5fde176b@dxpl.pdx.osdl.net>
	<44E25767.6010208@bellsouth.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:20126 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751237AbWHPSFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 14:05:05 -0400
To: Jay Cliburn <jacliburn@bellsouth.net>
In-Reply-To: <44E25767.6010208@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Aug 2006 18:23:19 -0500
Jay Cliburn <jacliburn@bellsouth.net> wrote:

> Stephen Hemminger wrote:
> > On Sun, 13 Aug 2006 19:11:42 -0500
> > Jay Cliburn <jacliburn@bellsouth.net> wrote:
> ...snip...
> >> I've read the LKML FAQ regarding new driver submissions, but it implies
> >> that the submitter be willing to maintain the driver, which I'm not
> >> qualified to do.  I haven't contacted Attansic to request a change to
> >> the above support statement, because my past attempts to contact vendors
> >> on matters of this tenor have been greeted with silence.
> > 
> > I would recommend the module author to see if they would GPL it.
> 
> Thank you for your reply.  I've contacted the author as you suggest.
> 

IANAL but because they used GPL code in the driver, one could argue
that they created a derived work covered by GPL already. But I learned in
preschool it is always better to ask than take.
