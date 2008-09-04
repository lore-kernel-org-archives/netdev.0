From: maximilian attems <max@stro.at>
Subject: skge_up in skge_change_mtu oops
Date: Thu, 4 Sep 2008 17:47:21 +0200
Message-ID: <20080904154721.GA15169@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:48561 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324AbYIDPr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 11:47:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

according to kerneloops this one shows pretty high up in the list
http://kerneloops.org/guilty.php?guilty=skge_up&version=2.6.26-release&start=1736704&end=1769471&class=oops

ifconfig seems reliably choking it, thanks for taking a look.

-- 
maks
