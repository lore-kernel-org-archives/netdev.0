From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [patch 0/2] af_iucv patches for linux-2.6.31
Date: Thu, 18 Jun 2009 14:44:54 +0200
Message-ID: <1245329094.14954.38.camel@braunu-laptop>
References: <20090618075446.890351000@linux.vnet.ibm.com>
	 <20090618.013410.04304670.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ursula.braun@de.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:52763 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441AbZFRMox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 08:44:53 -0400
In-Reply-To: <20090618.013410.04304670.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-06-18 at 01:34 -0700, David Miller wrote:
> From: Ursula Braun <ursula.braun@de.ibm.com>
> Date: Thu, 18 Jun 2009 09:54:46 +0200
> 
> > Hendrik has built 2 af_iucv patches fixing inappropriate return code handling
> > for sendmsg. They are built against linux-2.6.30. We would like to see them
> > included in 2.6.31 - if possible.
> 
> These patches do not apply cleanly against Linus's current tree nor
> net-next-2.6 which is what you should be subumitting patches again.
> 
> This late in the merge window it really behooves you to do anything
> other than submit patches against the previous release... it's
> almost guarenteed to fail, really.

Dave,

sorry, I did a git pull on linux-2.6.git first, and the af_iucv patches
applied cleanly on my system. Anyway, I understand that I have been too
late in the merge window. I will submit the patches against net-next-2.6
again.

Regards, Ursula

