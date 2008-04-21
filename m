From: David Miller <davem@davemloft.net>
Subject: Re: New GIT net tree naming...
Date: Mon, 21 Apr 2008 01:17:16 -0700 (PDT)
Message-ID: <20080421.011716.171281475.davem@davemloft.net>
References: <d0383f90804210053w538c20dfp6495072632320abe@mail.gmail.com>
	<20080421.170026.131839483.yoshfuji@linux-ipv6.org>
	<d0383f90804210113l5a9b41adra9a0125869917f3a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: ianbrn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59204
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751593AbYDUIRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 04:17:14 -0400
In-Reply-To: <d0383f90804210113l5a9b41adra9a0125869917f3a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ian Brown" <ianbrn@gmail.com>
Date: Mon, 21 Apr 2008 11:13:47 +0300

> Thanks.
> 
> >  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git
> >  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
> 
> OK , these URL worked for me.
> 
> last question:
> 
> Do I understand correctly - patches sent for this mailing list from
> now on are for davem/net-2.6.git tree and not for the
> davem/net-next-2.6.git ? or they can be for both, and we can
> understand from the patch title to which git tree they are ?

We're only accepting bug fixes now and they will go into
davem/net-2.6.git

After some time I'll start accepting feature and other non-bugfix
changes, and those will go into davem/net-next-2.6.git
