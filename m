From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 1/2] bnx2: factor out gzip unpacker
Date: Fri, 21 Sep 2007 23:48:05 +0100
Message-ID: <20070921234805.478efe15@the-village.bc.nu>
References: <200709211201.24475.vda.linux@googlemail.com>
	<200709211905.23946.vda.linux@googlemail.com>
	<15775.1190399812@turing-police.cc.vt.edu>
	<200709212018.06553.vda.linux@googlemail.com>
	<20070921220333.3b31afb5@the-village.bc.nu>
	<46F446C3.9050600@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Denys Vlasenko <vda.linux@googlemail.com>, Valdis.Kletnieks@vt.edu,
	David Miller <davem@davemloft.net>, mchan@broadcom.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:50529 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S932512AbXIUWlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 18:41:18 -0400
In-Reply-To: <46F446C3.9050600@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> According to an earlier thread, dgrs was never really maintained, 
> written for hardware that was never really distributed widely, and very 
> likely hasn't had users in years... if ever.
> 
> If that picture is accurate (it's a story I was told), then I am 
> definitely queueing up a deletion patch.

I think thats sensible. If someone whines it can be put back but I really
don't think anyone will
