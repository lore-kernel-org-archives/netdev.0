From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver fixes
Date: Fri, 04 Apr 2008 12:39:24 -0700 (PDT)
Message-ID: <20080404.123924.214795240.davem@davemloft.net>
References: <20080404063359.GA13309@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47745
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760641AbYDDTjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 15:39:24 -0400
In-Reply-To: <20080404063359.GA13309@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 4 Apr 2008 02:33:59 -0400

> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem

I think we need to defer the Tulip davicom ID removal patch, because
the tulip driver is the only one that works on sparc64 for davicom
chips, dmfe does not.

That's a regression, so I can't pull this in as-is.

I'm happy to discuss the davicom+sparc64 issue, but for now if
you could simply give me a tree which contains the other
bug fixes we can integrate those now.

Thanks!
