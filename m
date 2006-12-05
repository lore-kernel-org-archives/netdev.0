From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 0/7] iproute2: 2.6.19 updates and Mobile IPv6 support for
 ip command
Date: Tue, 05 Dec 2006 19:15:33 +0900
Message-ID: <457546C5.20700@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:58028 "EHLO mail.gomagoma.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S937435AbWLEKPg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 05:15:36 -0500
To: shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

These are iproute2 updates:

o Kernel header updates for 2.6.19
o libnetlink header updates to fit with 2.6.19 kernel
o Mobile IPv6 xfrm support for ip command

Since I could not build with the define nor find it on the kernel tree,
It also contains a patch which disable FIB_RULE_INVERT.

Please review and apply them.

Thanks,

-- 
Masahide NAKAMURA
