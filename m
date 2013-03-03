From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] libnetfilter_acct 1.0.2 release
Date: Sun, 3 Mar 2013 23:01:27 +0100
Message-ID: <20130303220127.GA19632@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="uAKRQypu60I7Lcqm"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37634 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754503Ab3CCWBs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Mar 2013 17:01:48 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        libnetfilter_acct 1.0.2

libnetfilter_acct is the userspace library providing interface to
extended accounting infrastructure starting Linux kernel 3.3.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/libnetfilter_acct/downloads.html
ftp://ftp.netfilter.org/pub/libnetfilter_acct/

Have fun!


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-libnetfilter_acct-1.0.2.txt"

Eric Leblond (2):
      Add include needed for integer types definition.
      Fix packets and bytes inversion.

Jan Engelhardt (3):
      build: resolve automake-1.12 warnings
      build: resolve compile abort on RHEL5 #1
      build: resolve compile abort on RHEL5 #2

Pablo Neira Ayuso (3):
      Merge git://git.inai.de/libnetfilter_acct master
      Partially revert "src: remove unnecessary castings"
      build: bump version to 1.0.2


--uAKRQypu60I7Lcqm--
