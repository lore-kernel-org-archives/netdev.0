From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] correct typo in __xfrm4_bundle_create()
Date: Wed, 05 Dec 2007 06:53:43 -0800 (PST)
Message-ID: <20071205.065343.81391789.davem@davemloft.net>
References: <d0383f90712050559o7ad78dbbm51f74984b591e66d@mail.gmail.com>
	<20071205.060316.74563693.davem@davemloft.net>
	<d0383f90712050633q5dadf8dbxa357a7d50f54528d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ianbrn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42256
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750898AbXLEOxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 09:53:50 -0500
In-Reply-To: <d0383f90712050633q5dadf8dbxa357a7d50f54528d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ian Brown" <ianbrn@gmail.com>
Date: Wed, 5 Dec 2007 16:33:56 +0200

> Hello,
> Sorry, but I had tried several times from 3 machines (without
> iptables/SELinux)  and git-clone
> gives "Connection refused" error.
> 
> git-clone git://kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.25.git 2.6.25

git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.25.git

I just publish my URL's in the:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git

canonical form so that they are easy to edit into:

	master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git

for SSH users and into:

	git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.25.git

for non-SSH users.
