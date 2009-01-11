From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 08/16] dma-debug: add core checking functions
Date: Sun, 11 Jan 2009 08:54:23 +0100
Message-ID: <20090111075423.GH9466@8bytes.org>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1231517970-20288-9-git-send-email-joerg.roedel@amd.com> <20090110231222.GL17917@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joerg Roedel <joerg.roedel@amd.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org,
	mingo@redhat.com
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 8bytes.org ([88.198.83.132]:41424 "EHLO 8bytes.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751131AbZAKHyY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jan 2009 02:54:24 -0500
Content-Disposition: inline
In-Reply-To: <20090110231222.GL17917@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 11, 2009 at 12:12:22AM +0100, Ingo Molnar wrote:
> 
> * Joerg Roedel <joerg.roedel@amd.com> wrote:
> 
> > +	/*
> > +	 *          * This may be no bug in reality - but most implementations of the
> > +	 *                   * DMA API don't handle this properly, so check for it here
> > +	 *                            */
> 
> You must be using Vim and copy & paste messed up? :)

Ups, true :) Thanks.

Joerg
