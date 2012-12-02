From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH 00/17] ATM fixes for pppoatm/br2684
Date: Sat, 01 Dec 2012 20:57:35 -0500
Message-ID: <201212020157.qB21vZiN011233@thirdoffive.cmf.nrl.navy.mil>
References: <1354382493.21562.347.camel@shinybook.infradead.org>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	krzysiek@podlesie.net
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:40393 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496Ab2LBB64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 20:58:56 -0500
In-reply-to: <1354382493.21562.347.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <1354382493.21562.347.camel@shinybook.infradead.org>,David Woodhouse writes:
>Possibly not even a bug at all, in fact =E2=80=94 GCC is fairly loose with =
>those
>warnings. But if it is a bug it's my fault. I'll take a look at that
>too. Not tonight though; I'm going out shortly and will only just manage
>the solos-pci fix.

it is not a bug, just gcc being pedantic.  gcc doesn't believe
that passing by reference it a form of initilization.
