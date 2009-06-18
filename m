From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/2] af_iucv patches for linux-2.6.31
Date: Thu, 18 Jun 2009 01:34:10 -0700 (PDT)
Message-ID: <20090618.013410.04304670.davem@davemloft.net>
References: <20090618075446.890351000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com
To: ursula.braun@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43093
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752470AbZFRIeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 04:34:07 -0400
In-Reply-To: <20090618075446.890351000@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>
Date: Thu, 18 Jun 2009 09:54:46 +0200

> Hendrik has built 2 af_iucv patches fixing inappropriate return code handling
> for sendmsg. They are built against linux-2.6.30. We would like to see them
> included in 2.6.31 - if possible.

These patches do not apply cleanly against Linus's current tree nor
net-next-2.6 which is what you should be subumitting patches again.

This late in the merge window it really behooves you to do anything
other than submit patches against the previous release... it's
almost guarenteed to fail, really.
