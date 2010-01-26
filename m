From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [GIT]: Networking
Date: Tue, 26 Jan 2010 06:33:26 +0000
Message-ID: <20100126063326.GA6360@ff.dom.local>
References: <20100125.165634.92235663.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:36552 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982Ab0AZGdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 01:33:32 -0500
Content-Disposition: inline
In-Reply-To: <20100125.165634.92235663.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26-01-2010 01:56, David Miller wrote:
> 1) SKY2 revert to fix a resume regression, from Stephem Hemminger
> 
> 2) We can end up trying to remove/proc/net/rt_acct when exiting
>    a namespace even when we didn't create it in the first place.
>    Fix from Alexey Dobriyan.
...
> Please pull, thanks a lot!
> 
> The following changes since commit f6760aa024199cfbce564311dc4bc4d47b6fb349:
>   Linus Torvalds (1):
>         Merge branch 'timers-fixes-for-linus' of git://git.kernel.org/.../tip/linux-2.6-tip
> 
> are available in the git repository at:
> 
>   master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

David, I hope I miss something, but there seem to be older things too:
...
> Jarek Poplawski (1):
>       ax25: netrom: rose: Fix timer oopses

Jarek P.
