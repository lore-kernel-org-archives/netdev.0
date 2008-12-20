From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 0/5]: SCTP updates
Date: Fri, 19 Dec 2008 20:47:46 -0500
Message-ID: <1229737672-28328-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:42261 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752250AbYLTBrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 20:47:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

The following series is set of updates for net-next.  It is primarily
new API and cleanups.  However patch 04/05 (Avoid memory overflow while
FWD-TSN chunk is received with bad stream ID) probably needs to be pushed
to stable.

Please apply.  If you want me to respin 04/05 against net-2.6, let me know.

Thanks
-vlad
