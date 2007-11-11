From: Mark Fasheh <mark.fasheh@oracle.com>
Subject: Re: [PATCH] NET: Add the helper kernel_sock_shutdown()
Date: Sun, 11 Nov 2007 12:45:28 -0800
Message-ID: <20071111204528.GQ28607@ca-server1.us.oracle.com>
References: <20071109000136.4700.8891.stgit@heimdal.trondhjem.org> <20071111180341.GP28607@ca-server1.us.oracle.com> <1194806414.11890.2.camel@heimdal.trondhjem.org>
Reply-To: Mark Fasheh <mark.fasheh@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Paul Clements <Paul.Clements@steeleye.com>,
	Steve French <sfrench@samba.org>,
	David Howells <dhowells@redhat.com>,
	David S Miller <davem@davemloft.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:22130 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757104AbXKKUqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 15:46:11 -0500
Content-Disposition: inline
In-Reply-To: <1194806414.11890.2.camel@heimdal.trondhjem.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 11, 2007 at 01:40:14PM -0500, Trond Myklebust wrote:
> 
> On Sun, 2007-11-11 at 10:03 -0800, Mark Fasheh wrote:
> > That looks pretty good - any objection to naming the enum and using that
> > name in the prototype for kernel_sock_shutdown() so it's even more obvious
> > what type of shutdown argument this expects?
> That would be fine by me. How about the attached patch?

Looks good to me, thanks!

Acked-by: Mark Fasheh <mark.fasheh@oracle.com>
	--Mark

--
Mark Fasheh
Senior Software Developer, Oracle
mark.fasheh@oracle.com
