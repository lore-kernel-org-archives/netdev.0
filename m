From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 5/5] dma: use dev_to_node to get node for device in
 dma_alloc_pages
Date: Mon, 23 Jul 2007 12:30:25 -0700
Message-ID: <20070723123025.708e14e2@schroedinger.engr.sgi.com>
References: <200707101641.17672.yinghai.lu@sun.com>
	<200707101653.09797.yinghai.lu@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>,
	Greg KH <greg@kroah.com>, rientjes@google.com,
	Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Yinghai Lu <Yinghai.Lu@Sun.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:56346 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1761360AbXGWTa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 15:30:28 -0400
In-Reply-To: <200707101653.09797.yinghai.lu@sun.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Jul 2007 16:53:09 -0700
Yinghai Lu <Yinghai.Lu@Sun.COM> wrote:

> [PATCH 5/5] dma: use dev_to_node to get node for device in
> dma_alloc_pages

Acked-by: Christoph Lameter <clameter@sgi.com>
