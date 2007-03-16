From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation [try #2]
Date: Fri, 16 Mar 2007 13:40:48 +0000
Message-ID: <20070316134048.GA3393@infradead.org>
References: <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:39080 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753528AbXCPNkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 09:40:51 -0400
Content-Disposition: inline
In-Reply-To: <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 16, 2007 at 12:50:08PM +0000, David Howells wrote:
>  (*) Make fs/afs/ use it and delete the current contents of net/rxrpc/

Having this done would be a really useful use case for getting the code
merged..

