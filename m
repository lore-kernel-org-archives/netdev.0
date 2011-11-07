From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: Re: commit 0bdb0bd0 breaks shutdown/reboot
Date: Mon, 7 Nov 2011 17:32:27 +0100
Message-ID: <20111107163227.GA17798@isilmar-3.linta.de>
References: <20111107153119.GA11724@comet.dominikbrodowski.net>
 <20111107081316.2e1cc2cb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar-3.linta.de ([188.40.101.200]:50001 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755744Ab1KGQc3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Nov 2011 11:32:29 -0500
Content-Disposition: inline
In-Reply-To: <20111107081316.2e1cc2cb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 07, 2011 at 08:13:16AM -0800, Stephen Hemminger wrote:
> Does this help?

Unfortunately, no. Reboots still fail.

> 
> Subject: sky2: block irq's on down
> 
> Need to block IRQ's from phy changes to prevent stray IRQ's when
> device is down.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Thanks anyway,
	Dominik
