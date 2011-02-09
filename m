From: kaber@trash.net
Subject: [PATCH 0/2] netfilter: netfilter update
Date: Wed,  9 Feb 2011 15:33:45 +0100
Message-ID: <1297262027-26237-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52821 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755131Ab1BIOeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Feb 2011 09:34:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

following are two IPVS patches for net-next-2.6, fixing:

- use of an incorrect lock in the SCTP module, from Simon

- a precedence bug in ip_vs_sync_switch_mode(), from Dan Carpenter

Please pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!
