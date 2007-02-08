From: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Subject: [PATCH 0/5] [XFRM,PFKEYV2]: MIGRATE support (take 3)
Date: Thu, 08 Feb 2007 12:09:29 +0900
Message-ID: <20070208113221.193F.SHINTA@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Francis Dupont <Francis.Dupont@point6.net>,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	yoshfuji@linux-ipv6.org, usagi-core@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sfc.wide.ad.jp ([203.178.142.146]:39526 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422744AbXBHDJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 22:09:32 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Let me re-post a patch set for MIGRATE support for XFRM/PFKEYv2.

The patch set consists of following 5 patches:

[PATCH (1/5)] [XFRM]: Extension for dynamic update of endpoint address(es)
[PATCH (2/5)] [XFRM]: User interface for handling XFRM_MSG_MIGRATE
[PATCH (3/5)] [XFRM]: CONFIG_XFRM_MIGRATE option
[PATCH (4/5)] [PFKEYV2]: Extension for dynamic update of endpoint address(es)
[PATCH (5/5)] [PFKEYV2]: CONFIG_NET_KEY_MIGRATE option

And it can also be fetched by git from following repository with
branch name "migrate-take3".

git://git.linux-ipv6.org/gitroot/shinta/net-2.6.21-migrate.git

Regards,
Shinta


