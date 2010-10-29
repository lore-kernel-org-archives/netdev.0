From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH 05/15] dec netdev: relocate DIGITAL based drivers to
 legacy
Date: Fri, 29 Oct 2010 07:37:59 +0100 (BST)
Message-ID: <alpine.LFD.2.00.1010290726010.25426@eddie.linux-mips.org>
References: <alpine.LFD.2.00.1010290545270.25426@eddie.linux-mips.org>        <20101028.224703.112589527.davem@davemloft.net>        <alpine.LFD.2.00.1010290647270.25426@eddie.linux-mips.org> <20101028.225356.39188490.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: paul.gortmaker@windriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:51534 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753248Ab0J2GiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 02:38:00 -0400
Received: from localhost.localdomain ([127.0.0.1]:43379 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S1491016Ab0J2Gh7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 08:37:59 +0200
In-Reply-To: <20101028.225356.39188490.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Oct 2010, David Miller wrote:

> >  See my proposal that crossed with your e-mail.  I think it fits the 
> > purpose very well. :)
> 
> No, it's foolish, see my reply.

 Well, you are the maintainer, so it's your call.  I disagree and I have 
given what I believe is a reasonable justification, but that's about as 
much as I can do -- I can't force it onto you.  As I say my concern is 
about the arbitrary assignment and not things being called "legacy" or 
"best-ever", "pre-y2k", or whatever.  And splitting a bunch of pieces of 
software that are loosely related to one another into two bunches isn't 
going to reduce clutter, but to spread it instead -- now you'll have 
clutter in two places rather than just one, so I think the change is just 
missing the point.  Again, as the maintainer it's your right to disagree.

 Thank you for the time you've taken to consider my comments nonetheless.

  Maciej
