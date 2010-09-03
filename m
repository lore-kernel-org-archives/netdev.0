From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bug #16626] Machine hangs with EIP at skb_copy_and_csum_dev
Date: Fri, 3 Sep 2010 09:06:20 +0000
Message-ID: <20100903090620.GA6645@ff.dom.local>
References: <4LwrqITm-eJ.A.r8G.eFueMB@chimera> <4AUWBNzTkbD.A.ey.cGueMB@chimera> <courier.4C7C99F2.00001F74@fs.ru.acad.bg> <20100831192659.GA3093@del.dom.local> <1283338251.2556.124.camel@edumazet-laptop> <4C80AB34.20501@fs.uni-ruse.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49467 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754432Ab0ICJGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 05:06:25 -0400
Content-Disposition: inline
In-Reply-To: <4C80AB34.20501@fs.uni-ruse.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 03, 2010 at 11:00:52AM +0300, Plamen Petrov wrote:
> ???? 01.9.2010 ??. 13:50, Eric Dumazet ????????????:
>
> I confirm that the above patch applied on top of v2.6.36-rc3 does not
> show the problems that all the kernels since v2.6.35 (both stable
> and Linus' tree) had.
>
> My problematic machine has been running the patched 36-rc3 for 36 hours,  
> and couning, with "generic receive offload" enabled only my tg3 nic.
>
> Thank you very much for the wonderful job, Eric!
> Thanks to you, too, Jarek!

Not at all! I only messed up a bit :-(

All credits to Eric and Plamen!

Thanks again,
Jarek P.
