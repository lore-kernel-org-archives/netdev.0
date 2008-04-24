From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 10/15] m68k: Some network drivers do not check the
	platform
Date: Thu, 24 Apr 2008 14:53:09 -0400
Message-ID: <20080424185309.GA22381@infradead.org>
References: <20080424182940.424312704@mail.of.borg> <20080424183242.943446357@mail.of.borg> <20080424184256.GA8531@infradead.org> <Pine.LNX.4.64.0804242045510.21224@anakin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-m68k@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:49516 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753891AbYDXSxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 14:53:11 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804242045510.21224@anakin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2008 at 08:51:17PM +0200, Geert Uytterhoeven wrote:
> I suppose you mean platform_*device*_register(), not
> platform_*driver*_register()?

Yes, sorry.

---end quoted text---
