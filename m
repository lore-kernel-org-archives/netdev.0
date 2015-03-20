From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v3 net-next 0/3] Add support for async socket operations
Date: Fri, 20 Mar 2015 07:45:38 +0100
Message-ID: <20150320064538.GA626@lst.de>
References: <20150319193118.11500.10463.stgit@tstruk-mobl1> <20150319195105.GS29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tadeusz Struk <tadeusz.struk@intel.com>, davem@davemloft.net,
	linux-aio@kvack.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, ying.xue@windriver.com, bcrl@kvack.org,
	linux-fsdevel@vger.kernel.org, hch@lst.de,
	linux-crypto@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:57362 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750801AbbCTGpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 02:45:42 -0400
Content-Disposition: inline
In-Reply-To: <20150319195105.GS29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2015 at 07:51:05PM +0000, Al Viro wrote:
> I think I can live with that.  Christoph, do you have any objections to
> that series?

Patch 1 looks fine to me which is probably what you care for.  I didn't have
time to look into the other two.
