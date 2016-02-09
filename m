From: David Howells <dhowells@redhat.com>
Subject: Pushing AF_RXRPC rewrite patches to net/next
Date: Tue, 09 Feb 2016 16:31:01 +0000
Message-ID: <9603.1455035461@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21538 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755446AbcBIQbE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 11:31:04 -0500
Content-ID: <9602.1455035461.1@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I've split 23 patches out of my AF_RXRPC rewrite so far.  If you look here:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-experimental

the penultimate patch is the remnant rewrite, the 23 patches below that are
ones I've split out of it.

Are you okay with me sending some of them your way now so that you don't get a
host all in one go, or would you prefer the mass invasion approach?

Note that I've moved things between files in some patches.  Where possible
I've made a patch that *just* moves from one file to another and then the next
patch modifies the new file.

Unless you're willing to take the remnant patch whole (which would be lovely
as splitting the patch is way more work than doing the rewrite, but I deem
unlikely), I still have some more splits I can make in that.

David
