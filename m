From: Simon Horman <horms@verge.net.au>
Subject: [GIT PULL] IPVS SCTP lock fix
Date: Thu,  3 Feb 2011 20:52:04 +0900
Message-ID: <1296733925-23131-1-git-send-email-horms@verge.net.au>
Cc: Randy Dunlap <randy.dunlap@oracle.com>
To: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:48266 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756294Ab1BCLwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 06:52:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick,

please consider pulling
git://git.kernel.org/pub/scm/linux/kernel/git/horms/lvs-test-2.6.git for-patrick
which contains a single patch to the IPVS SCTP module so that
it uses the correct lock.

