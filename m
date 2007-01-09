From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: kernel BUG in eth_alloc_tx_desc_index at drivers/net/mv643xx_eth.c:1069!
Date: Tue, 9 Jan 2007 11:52:44 +0100
Message-ID: <20070109105244.GD1703@ff.dom.local>
References: <7d01f9f00701051103q3ee6ed35q9fd0f778a18061b8@mail.gmail.com> <20070109092602.GC1703@ff.dom.local> <7d01f9f00701090227v60b37e5dy6afbf70ccde58bf2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:58543 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751332AbXAIKuw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 05:50:52 -0500
To: Thibaut VARENE <T-Bone@parisc-linux.org>
Content-Disposition: inline
In-Reply-To: <7d01f9f00701090227v60b37e5dy6afbf70ccde58bf2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 09, 2007 at 11:27:59AM +0100, Thibaut VARENE wrote:
...
> I suspected both and changed both the disk and the ram for quality
> parts, that I tested afterwards. Both passed thorough tests.

You wrote about half an hour, so overheating was also
considered, I presume.

> Finally, using the other NIC on the box (a VIA Rhine II, 100Mbps),
> works absolutely fine.

So it looks like the card/driver (or maybe this specimen?).
 
Jarek P.
