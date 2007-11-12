From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] NET: Add the helper kernel_sock_shutdown()
Date: Mon, 12 Nov 2007 12:22:18 +0000
Message-ID: <4145.1194870138@redhat.com>
References: <20071109000136.4700.8891.stgit@heimdal.trondhjem.org>
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	Paul Clements <Paul.Clements@steeleye.com>,
	Mark Fasheh <mark.fasheh@oracle.com>,
	Steve French <sfrench@samba.org>,
	David S Miller <davem@davemloft.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43808 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758174AbXKLMW6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 07:22:58 -0500
In-Reply-To: <20071109000136.4700.8891.stgit@heimdal.trondhjem.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> take a SHUT_RD/SHUT_WR/SHUT_RDWR argument instead of the

Hmmm...  Why SHUT_*?  Why not SHUTDOWN_*?

David
