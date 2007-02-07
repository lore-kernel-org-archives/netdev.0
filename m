From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [IPROUTE2] tc build failure and netfilter headers.
Date: Wed, 07 Feb 2007 16:33:53 +0900 (JST)
Message-ID: <20070207.163353.86698058.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54010 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965660AbXBGHc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 02:32:26 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen,

I think we should include include/linux/netfilter/{x_tables.h,xt_tcpudp.h}
in iproute2 distribution to avoid compilation failure of tc.

Regards,

--yoshfuji
