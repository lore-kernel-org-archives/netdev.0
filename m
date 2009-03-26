From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking for 2.6.30
Date: Thu, 26 Mar 2009 15:25:15 -0700 (PDT)
Message-ID: <20090326.152515.43533230.davem@davemloft.net>
References: <20090326.020714.36421849.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42541
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755456AbZCZWZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 18:25:28 -0400
In-Reply-To: <20090326.020714.36421849.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 26 Mar 2009 02:07:14 -0700 (PDT)

> 
> These are the networking updates for 2.6.30
> 
> The safest fix for the GRO stinker Ingo and others ran into
> is here as well, and I will push that to -stable once it
> hits your tree.

Just FYI, I've just pushed a merge of the changes you pulled in today
in order to resolve the one merge conflict that arose.

> Please pull, thanks a lot!
> 
> The following changes since commit 8e0ee43bc2c3e19db56a4adaa9a9b04ce885cd84:
>   Linus Torvalds (1):
>         Linux 2.6.29
> 
> are available in the git repository at:
> 
>   master.kernel.org:/pub/scm/linux/kernel/git/davem/net-next-2.6.git master

Thanks!
