From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] skge: use the DMA state API instead of the pci
 equivalents
Date: Fri, 14 May 2010 18:33:07 -0700
Message-ID: <20100514183307.6c14f294@nehalam>
References: <20100428095730K.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54246 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753127Ab0EOBdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 21:33:31 -0400
In-Reply-To: <20100428095730K.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Apr 2010 09:57:04 +0900
FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:

> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

Yes, this works fine. Sorry for the delay but that test system
was offline for several months and the disk went bad.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
