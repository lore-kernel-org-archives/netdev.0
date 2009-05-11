From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/1] dma-mapping: mark DMA_nBITS_MASK as deprecated fix
Date: Mon, 11 May 2009 14:46:46 +0200
Message-ID: <20090511124646.GK13954@elte.hu>
References: <20090510085618D.fujita.tomonori@lab.ntt.co.jp> <1241939066-10178-1-git-send-email-jirislaby@gmail.com> <20090511113659U.fujita.tomonori@lab.ntt.co.jp> <4A07EE1C.2010705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	yanghy@cn.fujitsu.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:48279 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751062AbZEKMrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2009 08:47:23 -0400
Content-Disposition: inline
In-Reply-To: <4A07EE1C.2010705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Jiri Slaby <jirislaby@gmail.com> wrote:

> On 05/11/2009 04:36 AM, FUJITA Tomonori wrote:
> > But I think that you need to resend a version of this patch against
> > tip. We need this patch in linux-next to warn some new users of these
> > deprecated macros.
> 
> It depends on Ingo if he doesn't mind to pick it up :).

Yes, i picked it up - dma-mapping.h changes generally get reviewed 
by and go via the IOMMU folks and is maintained in tip:core/iommu.

	Ingo
