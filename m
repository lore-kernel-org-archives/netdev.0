From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH -mm] ssb: open-code dma_alloc_coherent
Date: Mon, 15 Feb 2010 00:49:14 -0600
Message-ID: <4B78EE6A.3010207@lwfinger.net>
References: <20100215142111R.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, mb@bu3sch.de,
	davem@davemloft.net, stefano.brivio@polimi.it,
	akpm@linux-foundation.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f196.google.com ([209.85.210.196]:48333 "EHLO
	mail-yx0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752750Ab0BOGtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 01:49:19 -0500
In-Reply-To: <20100215142111R.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/14/2010 11:21 PM, FUJITA Tomonori wrote:
> This patch is against -mm since it depends on the DMA API changes in
> -mm.

Are the patches that implement these DMA API changes available for testing? I
don't keep an -mm tree.

Larry

