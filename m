From: David Miller <davem@davemloft.net>
Subject: Re: request-pull: Use static const
Date: Tue, 21 Dec 2010 13:27:36 -0800 (PST)
Message-ID: <20101221.132736.28825714.davem@davemloft.net>
References: <1292927173.1779.27.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49956
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751434Ab0LUV1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 16:27:07 -0500
In-Reply-To: <1292927173.1779.27.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 21 Dec 2010 02:26:13 -0800

> Resubmitting the remnants of an earlier discrete patchset.
> https://lkml.org/lkml/2010/11/20/209
> Consolidated into smaller patches.
> 
> The following changes since commit d9993be65a77f500ae926176baa264816bfe3816:
> 
>   Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6 (2010-12-20 13:24:14 -0800)
> 
> are available in the git repository at:
> 
>   git://repo.or.cz/linux-2.6/trivial-mods.git 20101221_static_const
> 
> Joe Perches (5):
>       tg3: Use DEFINE_PCI_DEVICE_TABLE
>       drivers/net/*.c: Use static const
>       usb: Use static const, consolidate code
>       tulip: Use DEFINE_PCI_DEVICE_TABLE and static const
>       drivers/net/*/: Use static const

Pulled, thanks Joe.
