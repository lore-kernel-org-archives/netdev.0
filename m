From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 0/3] netlink: fix wrong use of the flag NLM_F_MULTI
Date: Tue, 28 Apr 2015 18:33:47 +0200
Message-ID: <1430238831-29966-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, dmitry.tarnyaginuug.ch@6wind.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:35189 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030279AbbD1QeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 12:34:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The first three patches fix a wrong use of this flag.

Because it's not the first time that this kind of bug happens, it could be
good to find something to help people.

The only idea that I have is in the last patch. It's just an example, if
people agrees on it, I will update all users and submit it formally.
Any better idea is welcomed.

Regards,
Nicolas
