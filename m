From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFT 0/5] sky2: suspend/resume patchlets
Date: Tue, 13 Jun 2006 09:22:38 -0400
Message-ID: <448EBC1E.6070701@pobox.com>
References: <20060613081726.695812000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:25234 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932095AbWFMNWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 09:22:41 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060613081726.695812000@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> There were a several problems buried in suspend/resume. The real
> failure was caused by the idle timer not being stopped/restarted.
> But several other races, and cleanups were needed.
> 
> Since I don't have a machine that will suspend successfully with
> that hardware, I can't test it.


All five patches look OK to me.  Did Linus get the patches?  The emails 
were sent to linus@osdl.org not torvalds@osdl.org.

	Jeff



