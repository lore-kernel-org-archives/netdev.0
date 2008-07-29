From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: NETDEV WATCHDOG: wifi0: transmit timed out
Date: Tue, 29 Jul 2008 06:58:59 -0700
Message-ID: <20080729065859.2bcc65ed@infradead.org>
References: <20080525112308.03a5fda7.komurojun-mbn@nifty.com>
	<20080729215315.5a505fe7.komurojun-mbn@nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Komuro <komurojun-mbn@nifty.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41598 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754977AbYG2N7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 09:59:11 -0400
In-Reply-To: <20080729215315.5a505fe7.komurojun-mbn@nifty.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Jul 2008 21:53:15 +0900
Komuro <komurojun-mbn@nifty.com> wrote:

> Hi,
> 
> Please try to comment out the "WARN_ON_ONCE"
> at net/sched/sched_generic.c.
> 

"I have a hardware failure so I'll comment out the message that says
so, and then I won't have a failure". Yeah that'll work well.
