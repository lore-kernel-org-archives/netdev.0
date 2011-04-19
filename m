From: kaber@trash.net
Subject: [PATCH 0/3] netfilter: netfilter update
Date: Tue, 19 Apr 2011 16:31:29 +0200
Message-ID: <1303223492-13549-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39714 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755Ab1DSObk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 10:31:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

following is a small netfilter update for net-next, containing:

- a patch from Eric to remove some atomic ops in the *tables fastpath

- removal of an unnecessary ifdef from IPVS by Simon

- SCTP and UDPLITE support for ipset, from Jozsef

Please pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!
