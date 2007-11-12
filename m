From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] NET: Add the helper kernel_sock_shutdown()
Date: Mon, 12 Nov 2007 14:31:11 +0000
Message-ID: <5673.1194877871@redhat.com>
References: <1194874383.7465.8.camel@heimdal.trondhjem.org> <20071109000136.4700.8891.stgit@heimdal.trondhjem.org> <4145.1194870138@redhat.com>
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	Paul Clements <Paul.Clements@steeleye.com>,
	Mark Fasheh <mark.fasheh@oracle.com>,
	Steve French <sfrench@samba.org>,
	David S Miller <davem@davemloft.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:32772 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750695AbXKLOcs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 09:32:48 -0500
In-Reply-To: <1194874383.7465.8.camel@heimdal.trondhjem.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> SHUT_RD/SHUT_WR/SHUT_RDWR are the traditional names for these constants
> (see 'man 3 shutdown') and so should be easier to remember.

Good point.

David
