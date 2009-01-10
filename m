From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 08/16] dma-debug: add core checking functions
Date: Sun, 11 Jan 2009 00:12:22 +0100
Message-ID: <20090110231222.GL17917@elte.hu>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-9-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	dwmw2@infradead.org, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:52154 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753303AbZAJXMq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jan 2009 18:12:46 -0500
Content-Disposition: inline
In-Reply-To: <1231517970-20288-9-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Joerg Roedel <joerg.roedel@amd.com> wrote:

> +	/*
> +	 *          * This may be no bug in reality - but most implementations of the
> +	 *                   * DMA API don't handle this properly, so check for it here
> +	 *                            */

You must be using Vim and copy & paste messed up? :)

	Ingo
