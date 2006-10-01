From: Jeff Garzik <jeff@garzik.org>
Subject: Re: netdev-2.6.git frozen
Date: Sat, 30 Sep 2006 23:52:13 -0400
Message-ID: <451F3B6D.9060007@garzik.org>
References: <451F3A8F.7040608@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:61675 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751836AbWJADwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2006 23:52:15 -0400
To: Netdev List <netdev@vger.kernel.org>
In-Reply-To: <451F3A8F.7040608@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Similar to David's recent announcement, netdev-2.6.git is now closed to 
> new features.
> 
> Though really, [my fault] I should have posted this as soon as the merge 
> window opened.  The stuff that goes into each new release, when the 
> merge window opens, should be stuff that has already been through a 
> round of testing in -mm.
> 
> The updates presented in netdev -- e100, e1000, ixgb and sky2 -- will go 
> upstream tomorrow.  Everything else will be fixed.

s/fixed/fixes/

I wish "everything" was fixed, after tomorrow :)


> And the message for the future is:  don't wait until the merge window 
> opens, to submit your test.  Doing so means it doesn't get the normal 

s/test/code/

Apparently I need my morning Pepsi.


> amount of testing and review, and is thus discouraged.

