From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/14] Spidernet DMA coalescing
Date: Thu, 14 Dec 2006 17:35:34 +0000
Message-ID: <20061214173534.GA3452@infradead.org>
References: <20061213210010.GR4329@austin.ibm.com> <20061213210659.GA1915@austin.ibm.com> <20061214110517.GA13377@infradead.org> <20061214170737.GS4329@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	Jens Osterkamp <Jens.Osterkamp@gmx.de>,
	James K Lewis <jim@jklewis.com>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:37569 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932880AbWLNRfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 12:35:54 -0500
To: Linas Vepstas <linas@austin.ibm.com>
Content-Disposition: inline
In-Reply-To: <20061214170737.GS4329@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 14, 2006 at 11:07:37AM -0600, Linas Vepstas wrote:
> Being unclear on the concept, should a send a new version of this patch,
> or should I send a new patch that removes this?

For just the memset issue an incremental patch would be fine.  But given
the small mistake in the patch description a resend with the fixed
description mighrt be in order here.

