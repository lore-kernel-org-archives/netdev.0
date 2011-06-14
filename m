From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH net-next 0/24] bnx2x: New FW and support for 578xx
Date: Tue, 14 Jun 2011 19:52:21 +0100 (BST)
Message-ID: <alpine.LFD.2.02.1106141952070.8326@localhost6.localdomain6>
References: <201106141922.40906.vladz@broadcom.com> <20110614.133200.1595212089561436266.davem@davemloft.net> <1308072953.9492.4.camel@HP1> <20110614.134653.607599293786464713.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: mchan@broadcom.com, vladz@broadcom.com, bprakash@broadcom.com,
	eilong@broadcom.com, netdev@vger.kernel.org, dmitry@broadcom.com,
	yaniv.rosner@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:45970 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842Ab1FNSw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 14:52:27 -0400
In-Reply-To: <20110614.134653.607599293786464713.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Jun 2011, David Miller wrote:

> > When David Woodhouse integrates the firmware and a new firmware rpm is
> > made available for users, then the new driver will work.

Tarballs are made daily, as soon as the firmware is submitted (which 
doesn't have to wait until the driver is patched). There is no issue with 
bisecting, because any ABI change in the firmware means a *new* firmware 
file which can be instslled in *parallel*.

> This is terrible.

Nonsense. It just means you want to be using an up-to-date copy of the 
firmware, which is hardly a problem.

-- 
dwmw2

