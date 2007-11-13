From: David Miller <davem@davemloft.net>
Subject: Re: Re : Re : [PATCH][IPv6] Add ifindex field in ND user option
 messages
Date: Mon, 12 Nov 2007 17:52:55 -0800 (PST)
Message-ID: <20071112.175255.243883712.davem@davemloft.net>
References: <195892.80996.qm@web25711.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	rdenis@simphalempin.com
To: linkfanel@yahoo.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46035
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753209AbXKMBw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 20:52:56 -0500
In-Reply-To: <195892.80996.qm@web25711.mail.ukl.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pierre Ynard <linkfanel@yahoo.fr>
Date: Tue, 13 Nov 2007 01:19:47 +0000 (GMT)

> > > > Unfortunately you cannot change the layout of a structure
> > > > already exported to userspace, it is part of the ABI.
> > > 
> > > Well, I thought it would not be a problem, as it is not exactly
> > > released yet. We are also currently developping the
> > > corresponding RDNSS daemon and would be totally ready to
> > > handle this change :)
> > 
> > Was it an interface added to 2.6.24?
> 
> Yes.
> 
> http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=31910575a9de61e78065e93846e8e7a4894a18bf

Great, then we can in fact fix it and I will apply your
patch.

Thanks.
