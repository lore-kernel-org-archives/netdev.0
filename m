From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next iproute2 v2 0/2]netconf: add support for ignore route attribute
Date: Tue, 15 Mar 2016 02:32:10 +0000
Message-ID: <1458009132-21621-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:2874 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933284AbcCOC2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 22:28:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series add support for ignore route attribute.

v1->v2:
- update manual
- use rta_getattr_* instead of RTA_DATA
- fix code styles

Zhang Shengju (2):
  netconf: add support for ignore route attribute
  man: update netconf manual for new attributes

 ip/ipnetconf.c        | 25 +++++++++++++++++--------
 man/man8/ip-netconf.8 |  2 +-
 2 files changed, 18 insertions(+), 9 deletions(-)

-- 
1.8.3.1
