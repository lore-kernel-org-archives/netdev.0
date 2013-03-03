From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] nfacct 1.0.1 release
Date: Sun, 3 Mar 2013 23:04:06 +0100
Message-ID: <20130303220406.GA28022@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="9jxsPFA5p3P2qPhR"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39764 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753563Ab3CCWEM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Mar 2013 17:04:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        nfacct 1.0.1

nfacct is the command line tool to create/retrieve/delete accounting
objects (available since Linux kernel 3.3).

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/nfacct/downloads.html
ftp://ftp.netfilter.org/pub/nfacct/

Have fun!


--9jxsPFA5p3P2qPhR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-nfacct-1.0.1.txt"

Eric Leblond (2):
      nfacct: fix parsing of `xml' `reset' together.
      Add restore command

Pablo Neira Ayuso (1):
      build: bump version to 1.0.1


--9jxsPFA5p3P2qPhR--
