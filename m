From: Christian Kujau <christian@g-house.de>
Subject: Re: 2.6.20.4: NETDEV WATCHDOG and lockups
Date: Tue, 3 Apr 2007 10:47:16 +0100 (BST)
Message-ID: <Pine.LNX.4.64.0704031036440.3963@sheep.housecafe.de>
References: <20070403065810.GA1832@ff.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	malte@g-house.de
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.g-housing.de ([81.169.133.75]:48103 "EHLO mail.g-house.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965442AbXDCJrV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 05:47:21 -0400
In-Reply-To: <20070403065810.GA1832@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 3 Apr 2007, Jarek Poplawski wrote:
> Did you try with 8139cp instead of 8139too?

I forgot about that, thanks.

> (Maybe even try some other card to narrow the problem?)

We're try to convince our hosting provider to replace the NIC with a 
e1000.

> You could also try to test without ehci, if it's possible.

Sure, I think USB is not needed.

thanks for your input!

Christian.
-- 
BOFH excuse #387:

Your computer's union contract is set to expire at midnight.
