From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [git pull] rxrpc regression fix
Date: Fri, 10 Apr 2015 03:36:52 +0100
Message-ID: <20150410023652.GZ889@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:50869 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752818AbbDJCgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 22:36:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	I've pulled a bunch of AFS stuff from dhowells; most of that
stuff is for-next fodder, but the first commit in there is a 4.0
regression; seeing that it's net/rxrpc, I think it ought to go through
your tree.  Could you pull from
git://git.kernel.org/scm/pub/linux/kernel/git/viro/vfs.git rxrpc-fix

Shortlog:
David Howells (1):
      RxRPC: Fix the conversion to iov_iter

Diffstat:
 net/rxrpc/ar-output.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
