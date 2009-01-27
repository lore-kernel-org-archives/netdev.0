From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] net: add tracepoints to socket api
Date: Tue, 27 Jan 2009 13:47:04 -0500
Message-ID: <20090127184704.GA26403@infradead.org>
References: <20090127171857.GB14429@infradead.org> <20090127.092017.40699485.davem@davemloft.net> <20090127172323.GA7635@infradead.org> <20090127.102141.99756103.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@infradead.org, nhorman@tuxdriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:46747 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755187AbZA0SrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 13:47:06 -0500
Content-Disposition: inline
In-Reply-To: <20090127.102141.99756103.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2009 at 10:21:41AM -0800, David Miller wrote:
> The block layer already merged trace annotations.  I therefore see no
> harm in merging the net bits.

The block layer also has a consumer for them (blktrace) and soon a
second one (the ftrace plugin)

