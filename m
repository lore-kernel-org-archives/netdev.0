From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 0/5] selinux: add some missing nlmsg commands
Date: Wed,  8 Apr 2015 18:36:37 +0200
Message-ID: <1428511002-22329-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34488 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754623AbbDHQgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 12:36:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It's not a critical issue, thus the patches are based on net-next.

Patches are splitted because the 'Fixes' tag is not the same for all commands.

 security/selinux/nlmsgtab.c | 7 +++++++
 1 file changed, 7 insertions(+)

Regards,
Nicolas
