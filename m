From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] skge: use the DMA state API instead of the pci
 equivalents
Date: Mon, 3 May 2010 16:14:12 -0700
Message-ID: <20100503161412.3ced1c73@nehalam>
References: <20100428095730K.fujita.tomonori@lab.ntt.co.jp>
	<20100503.153226.267391665.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35441 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932475Ab0ECXOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 19:14:37 -0400
In-Reply-To: <20100503.153226.267391665.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 03 May 2010 15:32:26 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> Date: Wed, 28 Apr 2010 09:57:04 +0900
> 
> > This replace the PCI DMA state API (include/linux/pci-dma.h) with the
> > DMA equivalents since the PCI DMA state API will be obsolete.
> > 
> > No functional change.
> > 
> > For further information about the background:
> > 
> > http://marc.info/?l=linux-netdev&m=127037540020276&w=2
> > 
> > Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> 
> Stephen have you had a chance to smoke test this yet?
> I'd like to apply it as it's been rotting in patchwork
> for almost a week now.

Let me fire up that box.
