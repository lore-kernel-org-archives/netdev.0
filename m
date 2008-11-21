From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH 0/10] DMA-API debugging facility
Date: Fri, 21 Nov 2008 17:22:27 +0000
Message-ID: <1227288147.4901.220.camel@macbook.infradead.org>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
	 <1227286492.4901.208.camel@macbook.infradead.org>
	 <20081121165722.GD1386@amd.com>
	 <1227287215.4901.213.camel@macbook.infradead.org>
	 <20081121171802.GK733@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Joerg Roedel <joerg.roedel@amd.com>,
	Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:41989 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753377AbYKURWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 12:22:36 -0500
In-Reply-To: <20081121171802.GK733@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-11-21 at 18:18 +0100, Ingo Molnar wrote:
> Joerg, i'd suggest to make the generic conceptual bits generic, and 
> add an HAVE_DMA_DEBUG_SUPPORT Kconfig bool flag to every architecture 
> that enables it. It needs active changes to every architecture that 
> supports this facility.

Yes, that makes sense.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

