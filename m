From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: NETDEV WATCHDOG: wifi0: transmit timed out
Date: Wed, 30 Jul 2008 06:22:20 -0700
Message-ID: <20080730062220.08b2779a@infradead.org>
References: <20080729065859.2bcc65ed@infradead.org>
	<20080525112308.03a5fda7.komurojun-mbn@nifty.com>
	<20080729215315.5a505fe7.komurojun-mbn@nifty.com>
	<16453842.205951217418535898.komurojun-mbn@nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Komuro <komurojun-mbn@nifty.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59627 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbYG3NWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 09:22:36 -0400
In-Reply-To: <16453842.205951217418535898.komurojun-mbn@nifty.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Jul 2008 20:48:55 +0900 (JST)
Komuro <komurojun-mbn@nifty.com> wrote:

> 
> >
> >"I have a hardware failure so I'll comment out the message that says
> >so, and then I won't have a failure". Yeah that'll work well.
> 
> 
> O.K. The madwifi should be fixed.
> Thanks,

madwifi has many bigger issues; it's been number 1 in the kerneloops
top 10 for months and months now.

Feel free to fix it.. I can't.. it's a proprietary/binary driver.

-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
