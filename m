From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/5] FCrypt encryption module
Date: Thu, 8 Feb 2007 19:20:01 +0000
Message-ID: <20070208192001.GB32732@infradead.org>
References: <20070208163211.23973.5877.stgit@warthog.cambridge.redhat.com> <20070208163224.23973.81869.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	hch@infradead.org, arjan@infradead.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:43816 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423258AbXBHTUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 14:20:08 -0500
Content-Disposition: inline
In-Reply-To: <20070208163224.23973.81869.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 08, 2007 at 04:32:24PM +0000, David Howells wrote:
> +config CRYPTO_FCRYPT
> +	tristate "FCrypt cipher algorithm"
> +	select CRYPTO_ALGAPI
> +	select CRYPTO_BLKCIPHER
> +	help
> +	  FCrypt algorithm used by RxRPC.

this probably wants a litte more vebose description :)

