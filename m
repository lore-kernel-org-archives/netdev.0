From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH net-next v3 00/10] NCSI Support
Date: Wed, 20 Jul 2016 14:08:58 +1000
Message-ID: <1468987738.8568.92.camel@kernel.crashing.org>
References: <1468893265-10635-1-git-send-email-gwshan@linux.vnet.ibm.com>
	 <20160719.204935.206931978456558712.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, gwshan@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:53336 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751140AbcGTEJK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 00:09:10 -0400
In-Reply-To: <20160719.204935.206931978456558712.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-07-19 at 20:49 -0700, David Miller wrote:
> From: Gavin Shan <gwshan@linux.vnet.ibm.com>
> Date: Tue, 19 Jul 2016 11:54:15 +1000
> 
> > This series rebases on David's linux-net git repo ("master"
> branch). It's
> > to support NCSI stack on drivers/net/ethernet/faraday/ftgmac100.c.
> The
> > implementation is based on NCSI spec (version: 1.1.0):
> > https://www.dmtf.org/sites/default/files/standards/documents/DSP022
> 2_1.1.0.pdf
> 
> Series applied, thanks.

Thanks Dave. There was one little nit left in the Faraday driver but we
will send a follow up patch to fix it.

Cheers,
Ben.
