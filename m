From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IOAT: ioatdma needs to to play nice in a
 multi-dma-client world
Date: Fri, 24 Aug 2007 23:03:09 -0700 (PDT)
Message-ID: <20070824.230309.21227596.davem@davemloft.net>
References: <20070823001218.11648.49528.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, dan.j.williams@intel.com,
	jgarzik@pobox.com
To: shannon.nelson@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54000
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756246AbXHYGDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2007 02:03:12 -0400
In-Reply-To: <20070823001218.11648.49528.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shannon Nelson <shannon.nelson@intel.com>
Date: Wed, 22 Aug 2007 17:12:18 -0700

> Now that the DMA engine has a multi-client interface, fix the ioatdma
> driver to play along.  At the same time, remove a couple of unnecessary
> reads and writes.
> 
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>

Applied, thanks Shannon.
