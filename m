From: Linus Walleij <linus.walleij@stericsson.com>
Subject: Re: [GIT PATCH] ioat2: fix performance regression
Date: Fri, 15 Oct 2010 09:15:57 +0200
Message-ID: <4CB7FFAD.9060009@stericsson.com>
References: <20101013230248.32594.35857.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	Dave Jiang <dave.jiang@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Maciej Sosnowski <maciej.sosnowski@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"stable@kernel.org" <stable@kernel.org>,
	Richard Scobie <richard@sauce.co.nz>
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:44622 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756128Ab0JOHQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 03:16:53 -0400
In-Reply-To: <20101013230248.32594.35857.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Williams wrote:

> Commit 0793448 "DMAENGINE: generic channel status v2" changed the interface for
> how dma channel progress is retrieved.  It inadvertently exported an internal
> helper function ioat_tx_status() instead of ioat_dma_tx_status().

Acked-by: Linus Walleij <linus.walleij@stericsson.com>

Yours,
Linus Walleij
