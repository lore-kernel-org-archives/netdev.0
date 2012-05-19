From: Alan Cox <alan@linux.intel.com>
Subject: Re: [PATCH net-next] drivers/net: delete old 8bit ISA 3c501 driver.
Date: Sat, 19 May 2012 13:31:58 +0100
Message-ID: <20120519133158.1c74efc7@bob.linux.org.uk>
References: <1337362769-4676-1-git-send-email-paul.gortmaker@windriver.com>
	<20120518.235420.1669350688913610319.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:37877 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753297Ab2ESMQ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 May 2012 08:16:27 -0400
In-Reply-To: <20120518.235420.1669350688913610319.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > http://www.linuxquestions.org/questions/linux-networking-3/3com-3c501-card-not-detecting-934344/
> > 
> > Cc: Alan Cox <alan@linux.intel.com>
> > Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> 
> Alan, any objections?

Wrong reason to remove it, Perfectly reasonable it (and a pile of other
ISA cards) ought to be shown the door.

Check with the M68K people however. 3c501 won't matter to them but I'm
not sure which of the other chips ended up on Amiga ISA bridges. I know
NE2000 clones did.
