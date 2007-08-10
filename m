From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/4] Add ETHTOOL_[GS]FLAGS sub-ioctls
Date: Fri, 10 Aug 2007 16:56:17 -0400
Message-ID: <46BCD0F1.8040006@garzik.org>
References: <20070810202426.GA25050@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37683 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758882AbXHJU4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 16:56:19 -0400
In-Reply-To: <20070810202426.GA25050@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All this is currently checked into the 'eflags' branch of
git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git

But when everybody is happy with it, IMO we should get it into 
net-2.6.24.git, as it enables LRO.

	Jeff


